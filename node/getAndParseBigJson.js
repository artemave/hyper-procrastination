const httpism = require('httpism')
const cluster = require('cluster')
const numCPUs = require('os').cpus().length
const fs = require('fs')

const url = `http://${process.env.NGINX_HOST || 'localhost'}/citylots.json`

async function getJson() {
  const response = await httpism.get(url, {
    responseBody: 'text' // disable auto JSON.parse because we want to time parsing
  })
  return response.body
}

function extractData(data) {
  return data.features.reduce((result, f) => {
    const key = f.properties.FROM_ST
    result[key] = result[key] ? result[key] + 1 : 1
    return result
  }, {})
}

const numberOfJobs = 200

if (cluster.isMaster) {
  let startTime = new Date()
  let workersLeft = numCPUs
  let totalTimings = {
    request: '???', // Measuring accross async things gives weird numbers
    parse: 0,
    process: 0,
  }

  Array.apply(null, {length: numCPUs}).map(() => {
    return cluster.fork()
  }).forEach(worker => {
    worker.on('message', (message) => {
      totalTimings.parse += message.parse
      totalTimings.process += message.process
      workersLeft--

      if (workersLeft == 0) {
        totalTimings.total = (new Date() - startTime) / 1000
        totalTimings.parse = (totalTimings.parse / numCPUs) / 1000
        totalTimings.process = (totalTimings.process / numCPUs) / 1000

        console.log(`Time spent: ${totalTimings.request}ms request, ${totalTimings.parse}ms parse, ${totalTimings.process}ms process, ${totalTimings.total}ms total`);

        fs.writeFileSync(process.cwd() + '/results/node.json', JSON.stringify(totalTimings))

        process.exit(0)
      }
    })
  })
} else {
  let timings = {
    parse: 0,
    process: 0,
  }

  Promise.all(
    Array.apply(null, {length: numberOfJobs / numCPUs}).map(async () => {
      const response = await getJson()

      let t = new Date()
      const json = JSON.parse(response)
      timings.parse += new Date() - t

      t = new Date()
      const data = extractData(json)
      timings.process += new Date() - t

      console.log("Some data: " + Object.keys(data).length);
    })
  ).then(() => {
    process.send(timings)
  })
}
