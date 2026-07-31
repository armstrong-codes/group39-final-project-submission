const { requireAuth } = require(
  'C:/Users/hirwa/AppData/Roaming/npm/node_modules/firebase-tools/lib/requireAuth.js',
);
const { Client } = require(
  'C:/Users/hirwa/AppData/Roaming/npm/node_modules/firebase-tools/lib/apiv2.js',
);

const projectId = 'elimupath-733f9';
const firestore = new Client({
  auth: true,
  apiVersion: 'v1',
  urlPrefix: 'https://firestore.googleapis.com',
});

const schools = [
  ['akagera-hills-academy', 'Akagera Hills Academy', 'Kayonza', 'Private', 'Secondary', 'Mixed', 38, 'Senior 4', 'S4', 680000, 88.4, ['MPC', 'MCB', 'PCM'], ['Library', 'Science labs', 'Computer lab', 'Boarding']],
  ['amahoro-primary-school', 'Amahoro Primary School', 'Gasabo', 'Public', 'Primary', 'Mixed', 64, 'Primary', 'P4', 85000, 76.2, [], ['Library', 'Playground', 'School meals']],
  ['bright-future-college', 'Bright Future College', 'Kicukiro', 'Private', 'Secondary', 'Mixed', 25, 'Senior 5', 'S5', 920000, 91.1, ['PCB', 'PCM', 'MPC', 'MEG'], ['Boarding', 'Science labs', 'Computer lab', 'Sports grounds']],
  ['crown-girls-school', 'Crown Girls School', 'Nyarugenge', 'Private', 'Secondary', 'Girls', 30, 'Senior 1', 'S1', 750000, 89.7, ['HEG', 'MEG', 'MCB'], ['Boarding', 'Library', 'Science labs', 'Counselling']],
  ['eastland-technical-school', 'Eastland Technical School', 'Rwamagana', 'Public', 'TVET', 'Mixed', 42, 'Level 3', 'L3', 180000, 82.5, ['Software Development', 'Electronics', 'Construction'], ['Workshops', 'Computer lab', 'Internet', 'Sports grounds']],
  ['excel-nursery-primary', 'Excel Nursery and Primary School', 'Huye', 'Private', 'Nursery & Primary', 'Mixed', 55, 'Primary', 'P2', 260000, 80.3, [], ['Playground', 'Library', 'School meals', 'Transport']],
  ['glory-academy', 'Glory Academy', 'Gasabo', 'Private', 'Nursery & Secondary', 'Mixed', 20, 'Senior 3', 'S3', 540000, 84.9, ['MPC', 'MEG', 'HEG'], ['Library', 'Computer lab', 'Playground']],
  ['green-valley-school', 'Green Valley School', 'Musanze', 'Private', 'Primary & Secondary', 'Mixed', 47, 'Senior 2', 'S2', 610000, 87.6, ['PCB', 'MCB', 'HEG'], ['Boarding', 'Library', 'Science labs', 'Sports grounds']],
  ['heritage-boys-college', 'Heritage Boys College', 'Muhanga', 'Private', 'Secondary', 'Boys', 18, 'Senior 4', 'S4', 830000, 90.8, ['PCM', 'MPC', 'PCB'], ['Boarding', 'Science labs', 'Library', 'Football pitch']],
  ['hope-community-school', 'Hope Community School', 'Bugesera', 'Public', 'Primary & Secondary', 'Mixed', 72, 'Senior 1', 'S1', 95000, 73.8, ['MCB', 'HEG'], ['Library', 'School meals', 'Playground']],
  ['kigali-international-academy', 'Kigali International Academy', 'Kicukiro', 'International', 'Primary & Secondary', 'Mixed', 16, 'Secondary', 'Grade 10', 2450000, 94.3, ['Sciences', 'Humanities', 'Business'], ['Swimming pool', 'Science labs', 'Library', 'Transport']],
  ['lake-kivu-secondary-school', 'Lake Kivu Secondary School', 'Rubavu', 'Public', 'Secondary', 'Mixed', 53, 'Senior 5', 'S5', 120000, 79.6, ['PCB', 'MCB', 'HEG'], ['Boarding', 'Science labs', 'Library']],
  ['new-generation-school', 'New Generation School', 'Nyarugenge', 'Private', 'Primary & Secondary', 'Mixed', 34, 'Senior 6', 'S6', 790000, 92.0, ['PCM', 'MPC', 'PCB', 'MEG'], ['Computer lab', 'Science labs', 'Library', 'Transport']],
  ['nyungwe-science-school', 'Nyungwe Science School', 'Nyamagabe', 'Public', 'Secondary', 'Mixed', 28, 'Senior 4', 'S4', 145000, 93.2, ['PCM', 'PCB', 'MPC'], ['Boarding', 'Science labs', 'Computer lab', 'Library']],
  ['umucyo-learning-centre', 'Umucyo Learning Centre', 'Gicumbi', 'Private', 'Nursery & Primary', 'Mixed', 45, 'Primary', 'P5', 310000, 81.7, [], ['Library', 'Playground', 'School meals', 'Transport']],
];

function value(item) {
  if (typeof item === 'string') return { stringValue: item };
  if (typeof item === 'boolean') return { booleanValue: item };
  if (Number.isInteger(item)) return { integerValue: String(item) };
  if (typeof item === 'number') return { doubleValue: item };
  if (Array.isArray(item)) return { arrayValue: { values: item.map(value) } };
  throw new Error(`Unsupported Firestore value: ${item}`);
}

function documentFields(row) {
  const [id, name, district, type, level, gender, spots, spotsLevel, spotsClass, fees, performance, combinations, facilities] = row;
  const emailName = id.replace(/-/g, '.');
  const fields = {
    name, district, location: district, type, sector: type, level, gender,
    combinations, educationStages: level.includes('Primary') ? ['Nursery', 'Primary'] : ['Secondary'],
    availableSpots: spots, availableSpotsLevel: spotsLevel, availableSpotsClass: spotsClass,
    schoolFees: fees, performanceIndex: performance, facilities,
    email: `${emailName}@elimupath.rw`, phone: `+250 78${String(1000000 + schools.indexOf(row) * 7319).slice(-7)}`,
    contact: `+250 78${String(1000000 + schools.indexOf(row) * 7319).slice(-7)}`,
    photos: [], imageUrls: [], admissionStatus: spots > 0, isActive: true,
    verified: performance >= 80, ownerId: 'elimupath-seed', adminId: 'elimupath-seed',
  };
  return Object.fromEntries(Object.entries(fields).map(([key, item]) => [key, value(item)]));
}

async function main() {
  await requireAuth({ project: projectId });
  const base = `projects/${projectId}/databases/(default)/documents`;
  const now = new Date().toISOString();
  const writes = schools.map((row) => ({
    update: {
      name: `${base}/schools/${row[0]}`,
      fields: {
        ...documentFields(row),
        createdAt: { timestampValue: now },
        updatedAt: { timestampValue: now },
      },
    },
  }));
  const response = await firestore.post(`${base}:commit`, { writes });
  console.log(`Seeded ${response.body.writeResults.length} schools.`);
}

main().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
