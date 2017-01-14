import httpism from 'httpism'

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

let timings = {
  request: '???', // the naive approach used for the other metrics does not work: it seems to return totalTime * number of tests
  parse: 0,
  process: 0,
}
let startTime = new Date()

Promise.all(
  Array.apply(null, {length: 200}).map(async () => {
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
  let totalTime = new Date() - startTime
  console.log(`Time spent: ${timings.request}ms request, ${timings.parse}ms parse, ${timings.process}ms process, ${totalTime}ms total`);
})
