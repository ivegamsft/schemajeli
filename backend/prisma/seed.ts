import { PrismaClient, Role } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Create admin user
  const adminPasswordHash = await bcrypt.hash('Admin@123', 10);
  const adminUser = await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      email: 'admin@schemajeli.com',
      passwordHash: adminPasswordHash,
      fullName: 'System Administrator',
      role: Role.ADMIN,
      isActive: true,
    },
  });
  console.log('✅ Admin user created:', adminUser.username);

  // Create editor user
  const editorPasswordHash = await bcrypt.hash('Editor@123', 10);
  const editorUser = await prisma.user.upsert({
    where: { username: 'editor' },
    update: {},
    create: {
      username: 'editor',
      email: 'editor@schemajeli.com',
      passwordHash: editorPasswordHash,
      fullName: 'Database Editor',
      role: Role.EDITOR,
      isActive: true,
    },
  });
  console.log('✅ Editor user created:', editorUser.username);

  // Create viewer user
  const viewerPasswordHash = await bcrypt.hash('Viewer@123', 10);
  const viewerUser = await prisma.user.upsert({
    where: { username: 'viewer' },
    update: {},
    create: {
      username: 'viewer',
      email: 'viewer@schemajeli.com',
      passwordHash: viewerPasswordHash,
      fullName: 'Database Viewer',
      role: Role.VIEWER,
      isActive: true,
    },
  });
  console.log('✅ Viewer user created:', viewerUser.username);

  // Create sample abbreviations
  const abbreviations = [
    { source: 'Account', abbreviation: 'ACCT', definition: 'Financial account', isPrimeClass: true, category: 'Finance' },
    { source: 'Address', abbreviation: 'ADDR', definition: 'Location address', isPrimeClass: true, category: 'General' },
    { source: 'Amount', abbreviation: 'AMT', definition: 'Monetary amount', isPrimeClass: false, category: 'Finance' },
    { source: 'Company', abbreviation: 'CO', definition: 'Business company', isPrimeClass: true, category: 'Business' },
    { source: 'Customer', abbreviation: 'CUST', definition: 'Customer entity', isPrimeClass: true, category: 'Business' },
    { source: 'Database', abbreviation: 'DB', definition: 'Database system', isPrimeClass: true, category: 'Technology' },
    { source: 'Department', abbreviation: 'DEPT', definition: 'Organizational department', isPrimeClass: false, category: 'Business' },
    { source: 'Description', abbreviation: 'DESC', definition: 'Descriptive text', isPrimeClass: false, category: 'General' },
    { source: 'Document', abbreviation: 'DOC', definition: 'Document record', isPrimeClass: true, category: 'General' },
    { source: 'Employee', abbreviation: 'EMP', definition: 'Employee record', isPrimeClass: true, category: 'HR' },
    { source: 'Identifier', abbreviation: 'ID', definition: 'Unique identifier', isPrimeClass: false, category: 'General' },
    { source: 'Number', abbreviation: 'NBR', definition: 'Numeric value', isPrimeClass: false, category: 'General' },
    { source: 'Order', abbreviation: 'ORD', definition: 'Purchase order', isPrimeClass: true, category: 'Business' },
    { source: 'Product', abbreviation: 'PROD', definition: 'Product item', isPrimeClass: true, category: 'Business' },
    { source: 'Quantity', abbreviation: 'QTY', definition: 'Quantity amount', isPrimeClass: false, category: 'General' },
    { source: 'Reference', abbreviation: 'REF', definition: 'Reference field', isPrimeClass: false, category: 'General' },
    { source: 'Status', abbreviation: 'STAT', definition: 'Status indicator', isPrimeClass: false, category: 'General' },
    { source: 'Transaction', abbreviation: 'TXN', definition: 'Transaction record', isPrimeClass: true, category: 'Finance' },
    { source: 'User', abbreviation: 'USR', definition: 'User account', isPrimeClass: true, category: 'Security' },
    { source: 'Value', abbreviation: 'VAL', definition: 'Value field', isPrimeClass: false, category: 'General' },
  ];

  for (const abbr of abbreviations) {
    await prisma.abbreviation.upsert({
      where: { abbreviation: abbr.abbreviation },
      update: {},
      create: {
        ...abbr,
        createdById: adminUser.id,
      },
    });
  }
  console.log(`✅ Created ${abbreviations.length} abbreviations`);

  // Create sample server
  const sampleServer = await prisma.server.upsert({
    where: { name: 'PROD-DB-01' },
    update: {},
    create: {
      name: 'PROD-DB-01',
      description: 'Production PostgreSQL Server',
      host: 'prod-db-01.example.com',
      port: 5432,
      rdbmsType: 'POSTGRESQL',
      location: 'US-EAST-1',
      status: 'ACTIVE',
      createdById: adminUser.id,
    },
  });
  console.log('✅ Sample server created:', sampleServer.name);

  // Create sample database
  const sampleDatabase = await prisma.database.create({
    data: {
      serverId: sampleServer.id,
      name: 'schemajeli_prod',
      description: 'SchemaJeli Production Database',
      purpose: 'Main application database for metadata repository',
      status: 'ACTIVE',
      createdById: adminUser.id,
    },
  });
  console.log('✅ Sample database created:', sampleDatabase.name);

  // Create sample table
  const sampleTable = await prisma.table.create({
    data: {
      databaseId: sampleDatabase.id,
      name: 'customers',
      description: 'Customer master table',
      tableType: 'TABLE',
      rowCountEstimate: 10000,
      status: 'ACTIVE',
      createdById: adminUser.id,
    },
  });
  console.log('✅ Sample table created:', sampleTable.name);

  // Create sample elements
  const elements = [
    { name: 'cust_id', description: 'Customer ID', dataType: 'UUID', isPrimaryKey: true, isNullable: false, position: 1 },
    { name: 'cust_name', description: 'Customer full name', dataType: 'VARCHAR', length: 255, isNullable: false, position: 2 },
    { name: 'cust_email', description: 'Customer email address', dataType: 'VARCHAR', length: 255, isNullable: true, position: 3 },
    { name: 'cust_phone', description: 'Customer phone number', dataType: 'VARCHAR', length: 20, isNullable: true, position: 4 },
    { name: 'acct_nbr', description: 'Account number', dataType: 'VARCHAR', length: 50, isNullable: false, position: 5 },
    { name: 'created_at', description: 'Record creation timestamp', dataType: 'TIMESTAMP', isNullable: false, defaultValue: 'NOW()', position: 6 },
  ];

  for (const elem of elements) {
    await prisma.element.create({
      data: {
        ...elem,
        tableId: sampleTable.id,
        createdById: adminUser.id,
      },
    });
  }
  console.log(`✅ Created ${elements.length} sample elements`);

  console.log('🎉 Database seed completed successfully!');
  console.log('\n📋 Default accounts:');
  console.log('   Admin:  admin / Admin@123');
  console.log('   Editor: editor / Editor@123');
  console.log('   Viewer: viewer / Viewer@123');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
