const fs = require('fs');
const path = require('path');
const { files, imageUrl } = require('./assign_school_images.js');

const outputDirectory = path.join('assets', 'images', 'schools');
fs.mkdirSync(outputDirectory, { recursive: true });

async function main() {
  for (let index = 0; index < files.length; index += 1) {
    const extension = files[index].toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    const destination = path.join(
      outputDirectory,
      `school_${String(index + 1).padStart(2, '0')}.${extension}`,
    );
    if (fs.existsSync(destination) && fs.statSync(destination).size > 10000) {
      console.log(`Kept ${index + 1}/${files.length}: ${destination}`);
      continue;
    }
    let response;
    for (let attempt = 1; attempt <= 5; attempt += 1) {
      response = await fetch(imageUrl(files[index]), {
        headers: { 'User-Agent': 'ElimuPath educational app image setup/1.0' },
      });
      if (response.ok) break;
      if (response.status !== 429 || attempt === 5) {
        throw new Error(`${response.status} while downloading ${files[index]}`);
      }
      await new Promise((resolve) => setTimeout(resolve, attempt * 5000));
    }
    fs.writeFileSync(destination, Buffer.from(await response.arrayBuffer()));
    console.log(`Downloaded ${index + 1}/${files.length}: ${destination}`);
    await new Promise((resolve) => setTimeout(resolve, 3000));
  }
}

main().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
