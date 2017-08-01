const http = require('http')
const assert = require('assert')
const cluster = require('cluster')
const numCPUs = require('os').cpus().length
const fs = require('fs')
const testProfile = require('./test-profile')
const promiseLimit = require('promise-limit')

const url = `http://${process.env.NGINX_HOST || 'localhost'}/${testProfile.inputFile}`
const numberOfJobs = testProfile.numberOfJobs

function getJson () {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      const {statusCode} = res
      if (statusCode === 200) {
        res.setEncoding('utf8')
        let rawData = ''
        res.on('data', (chunk) => { rawData += chunk })
        res.on('end', () => {
          try {
            const parsedData = JSON.parse(rawData)
            resolve(parsedData)
          } catch (e) {
            reject(e.message)
          }
        })
      } else {
        res.resume()
        reject(new Error(`Request failed with status ${statusCode}`))
      }
    }).on('error', (e) => {
      reject(e)
    })
  })
}

function extractData (data) {
  return data.features.reduce((result, f) => {
    const key = f.properties.FROM_ST
    result[key] = result[key] ? result[key] + 1 : 1
    return result
  }, {})
}

if (cluster.isMaster) {
  let startTime = new Date()
  let workersLeft = numCPUs
  console.log('Running...')

  Array.apply(null, {length: numCPUs}).map(() => {
    return cluster.fork()
  }).forEach(worker => {
    worker.on('message', () => {
      workersLeft--

      if (workersLeft === 0) {
        const totalTime = (new Date() - startTime) / 1000
        console.log(`Time spent: ${totalTime}ms`)

        const report = Object.assign(testProfile, {tech: 'node', totalTime})
        fs.writeFileSync(process.cwd() + `/results/node-${testProfile.number}.json`, JSON.stringify(report))
        process.exit(0)
      }
    })
  })
} else {
  const limit = promiseLimit(1024)
  Promise.all(
    Array.apply(null, {length: numberOfJobs / numCPUs}).map(() => limit(async () => {
      const response = await getJson()
      const data = extractData(response)
      assert.equal(Object.keys(data).length, testProfile.expectedNumberOfKeys)
    }))
  ).then(() => {
    process.send('done')
  }).catch(e => {
    console.error(e)
  })
}
