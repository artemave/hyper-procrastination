import httpism from 'httpism'

const url = `http://${process.env.NGINX_HOST || 'localhost'}/citylots.json`

async function getJson() {
  const response = await httpism.get(url)
  return response.body
}

function extractData(data) {
  return data.features.reduce((result, f) => {
    const key = f.properties.FROM_ST

    if (result[key]) {
      result[key] += 1
    } else {
      result[key] = 1
    }

    return result
  }, {})
}

let startTime = new Date()

Promise.all(
  Array.apply(null, {length: 200}).map(async () => {
    const json = await getJson()
    const data = extractData(json)
    console.log("Some data: " + Object.keys(data).length);
  })
).then(() => {
  console.log(`Time spent: ${new Date() - startTime}ms`);
})
