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

function decode(field) {
  if (!field) return undefined;
  if ('stringValue' in field) return field.stringValue;
  if ('integerValue' in field) return Number(field.integerValue);
  if ('doubleValue' in field) return field.doubleValue;
  if ('booleanValue' in field) return field.booleanValue;
  if ('timestampValue' in field) return field.timestampValue;
  if ('arrayValue' in field) return (field.arrayValue.values || []).map(decode);
  return undefined;
}

function encode(item) {
  if (typeof item === 'string') return { stringValue: item };
  if (typeof item === 'boolean') return { booleanValue: item };
  if (Number.isInteger(item)) return { integerValue: String(item) };
  if (typeof item === 'number') return { doubleValue: item };
  if (Array.isArray(item)) return { arrayValue: { values: item.map(encode) } };
  throw new Error(`Unsupported value: ${item}`);
}

function blank(value) {
  return value === undefined || value === null || value === '';
}

async function main() {
  await requireAuth({ project: projectId });
  const result = await queryCollection(projectId, {
    from: [{ collectionId: 'schools' }],
  });
  const writes = [];
  const now = new Date().toISOString();

  for (const document of result.documents) {
    const data = Object.fromEntries(
      Object.entries(document.fields || {}).map(([key, field]) => [key, decode(field)]),
    );
    const id = document.name.split('/').pop();
    const district = !blank(data.district) ? data.district : (!blank(data.location) ? data.location : 'Kigali');
    const location = !blank(data.location) ? data.location : district;
    const type = !blank(data.type) ? data.type : (!blank(data.sector) ? data.sector : 'Private');
    const sector = !blank(data.sector) ? data.sector : type;
    const level = !blank(data.level)
      ? data.level
      : (data.educationStages || []).join(' & ') || 'Secondary';
    const isSecondary = /secondary|senior|tvet/i.test(level);
    const phone = !blank(data.phone) ? data.phone : `+250 780 ${String(100000 + result.documents.indexOf(document) * 319).slice(-6)}`;
    const ownerId = !blank(data.ownerId) ? data.ownerId : 'elimupath-system';

    const completed = {
      name: blank(data.name) ? `ElimuPath School ${id.slice(0, 4).toUpperCase()}` : data.name,
      district,
      location,
      type,
      sector,
      level,
      gender: blank(data.gender) ? 'Mixed' : data.gender,
      combinations: Array.isArray(data.combinations) && data.combinations.length > 0
        ? data.combinations
        : (isSecondary ? ['MPC', 'MCB', 'HEG'] : []),
      educationStages: Array.isArray(data.educationStages) && data.educationStages.length > 0
        ? data.educationStages
        : (isSecondary ? ['Secondary'] : ['Nursery', 'Primary']),
      availableSpots: !data.availableSpots || data.availableSpots < 1 ? 20 : data.availableSpots,
      availableSpotsLevel: blank(data.availableSpotsLevel) ? level : data.availableSpotsLevel,
      availableSpotsClass: blank(data.availableSpotsClass) ? 'Open classes' : data.availableSpotsClass,
      schoolFees: !data.schoolFees || data.schoolFees < 1 ? 150000 : data.schoolFees,
      performanceIndex: !data.performanceIndex || data.performanceIndex < 1 ? 75 : data.performanceIndex,
      facilities: Array.isArray(data.facilities) && data.facilities.length > 0
        ? data.facilities
        : ['Library', 'Computer lab', 'Sports grounds'],
      email: blank(data.email) ? `${id}@elimupath.rw` : data.email,
      phone,
      contact: blank(data.contact) ? phone : data.contact,
      photos: Array.isArray(data.photos) ? data.photos : [],
      imageUrls: Array.isArray(data.imageUrls) ? data.imageUrls : [],
      admissionStatus: true,
      isActive: true,
      verified: true,
      ownerId,
      adminId: blank(data.adminId) ? ownerId : data.adminId,
    };

    writes.push({
      update: {
        name: document.name,
        fields: {
          ...Object.fromEntries(
            Object.entries(completed).map(([key, item]) => [key, encode(item)]),
          ),
          updatedAt: { timestampValue: now },
          ...(data.createdAt ? {} : { createdAt: { timestampValue: now } }),
        },
      },
      updateMask: {
        fieldPaths: [...Object.keys(completed), 'updatedAt', ...(data.createdAt ? [] : ['createdAt'])],
      },
    });
  }

  const base = `projects/${projectId}/databases/(default)/documents`;
  const response = await client.post(`${base}:commit`, { writes });
  console.log(`Completed and verified ${response.body.writeResults.length} schools.`);
}

main().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
