const { requireAuth } = require(
  'C:/Users/hirwa/AppData/Roaming/npm/node_modules/firebase-tools/lib/requireAuth.js',
);
const { Client } = require(
  'C:/Users/hirwa/AppData/Roaming/npm/node_modules/firebase-tools/lib/apiv2.js',
);
const { queryCollection } = require(
  'C:/Users/hirwa/AppData/Roaming/npm/node_modules/firebase-tools/lib/gcp/firestore.js',
);

const projectId = 'elimupath-733f9';
const client = new Client({
  auth: true,
  apiVersion: 'v1',
  urlPrefix: 'https://firestore.googleapis.com',
});

const files = [
  'Ecole international de kigali.jpg',
  'Ecole muhihi entree en classe.jpg',
  'Ecole muhihi pignon au soleil.jpg',
  'Ecole muhihi vuedeschamps.jpg',
  'Ecole muhihi vueplongeante.jpg',
  'Ishuri rya Green Country.jpg',
  "Kiruhura Primary School Classrooms - Les salles de classe de l'école primaire de Kiruhura (4186582681).jpg",
  'NyagatareSchool.jpg',
  'School building of Nyarugugu Primary school (5966428645).jpg',
  'New Kindergarten in Rugarama Village.jpg',
  'Rwanda Classroom.jpg',
  'Rwanda schoolchildren.jpg',
  'Kagugu Classroom (4844912130).jpg',
  'Children playing in front of the lecture room - Les enfants jouant devant les salles de classe (4388823439).jpg',
  'Inside College Class.jpg',
  'Juru Secondary School Smart Classroom.jpg',
  'ICT IN EDUCATION.jpg',
];

function imageUrl(file) {
  return `https://commons.wikimedia.org/wiki/Special:Redirect/file/${encodeURIComponent(file)}?width=1200`;
}

function sourceUrl(file) {
  return `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(file)}`;
}

function assetUrl(index, file) {
  const extension = file.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
  return `assets/images/schools/school_${String(index + 1).padStart(2, '0')}.${extension}`;
}

async function main() {
  await requireAuth({ project: projectId });
  const result = await queryCollection(projectId, {
    from: [{ collectionId: 'schools' }],
    orderBy: [{ field: { fieldPath: 'name' }, direction: 'ASCENDING' }],
  });
  if (result.documents.length !== files.length) {
    throw new Error(`Expected ${files.length} schools, found ${result.documents.length}.`);
  }

  const now = new Date().toISOString();
  const writes = result.documents.map((document, index) => {
    const file = files[index];
    const url = assetUrl(index, file);
    return {
      update: {
        name: document.name,
        fields: {
          imageUrls: { arrayValue: { values: [{ stringValue: url }] } },
          photos: { arrayValue: { values: [{ stringValue: url }] } },
          imageSourceUrl: { stringValue: sourceUrl(file) },
          imageAttribution: {
            stringValue: 'Representative Rwanda education photo from Wikimedia Commons; see source for author and license.',
          },
          updatedAt: { timestampValue: now },
        },
      },
      updateMask: {
        fieldPaths: [
          'imageUrls',
          'photos',
          'imageSourceUrl',
          'imageAttribution',
          'updatedAt',
        ],
      },
    };
  });

  const base = `projects/${projectId}/databases/(default)/documents`;
  const response = await client.post(`${base}:commit`, { writes });
  console.log(`Assigned unique Rwanda school images to ${response.body.writeResults.length} schools.`);
}

module.exports = { files, imageUrl, sourceUrl, assetUrl };

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message || error);
    process.exitCode = 1;
  });
}
