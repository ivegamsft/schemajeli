import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Clear existing data
  console.log('🗑️  Clearing existing data...');
  await prisma.auditLog.deleteMany({});
  await prisma.abbreviation.deleteMany({});
  await prisma.element.deleteMany({});
  await prisma.table.deleteMany({});
  await prisma.database.deleteMany({});
  await prisma.server.deleteMany({});
  await prisma.user.deleteMany({});

  // 1. Create Users
  console.log('👥 Creating users...');
  const adminPassword = await bcrypt.hash('Admin@123', 10);
  const editorPassword = await bcrypt.hash('Editor@123', 10);
  const viewerPassword = await bcrypt.hash('Viewer@123', 10);

  const admin = await prisma.user.create({
    data: {
      email: 'admin@schemajeli.com',
      firstName: 'Admin',
      lastName: 'User',
      password: adminPassword,
      role: 'ADMIN',
      isActive: true,
      lastLogin: new Date(),
    },
  });

  const editor = await prisma.user.create({
    data: {
      email: 'editor@schemajeli.com',
      firstName: 'Editor',
      lastName: 'User',
      password: editorPassword,
      role: 'EDITOR',
      isActive: true,
      lastLogin: new Date(),
    },
  });

  const viewer = await prisma.user.create({
    data: {
      email: 'viewer@schemajeli.com',
      firstName: 'Viewer',
      lastName: 'User',
      password: viewerPassword,
      role: 'VIEWER',
      isActive: true,
      lastLogin: new Date(),
    },
  });


  // 2. Create Servers
  console.log('🖥️  Creating servers...');

  const informixServer = await prisma.server.create({
    data: {
      name: 'PROD-INFX-001',
      host: 'informix.prod.example.com',
      port: 9088,
      rdbmsType: 'INFORMIX',
      purpose: 'Production Informix data warehouse',
      location: 'Toronto, Canada',
      adminContact: 'admin@example.com',
      isActive: true,
    },
  });

  const postgresServer = await prisma.server.create({
    data: {
      name: 'PROD-PG-001',
      host: 'postgres.prod.example.com',
      port: 5432,
      rdbmsType: 'POSTGRESQL',
      purpose: 'Production PostgreSQL application database',
      location: 'Vancouver, Canada',
      adminContact: 'pgadmin@example.com',
      isActive: true,
    },
  });

  const mysqlServer = await prisma.server.create({
    data: {
      name: 'PROD-MYSQL-001',
      host: 'mysql.prod.example.com',
      port: 3306,
      rdbmsType: 'MYSQL',
      purpose: 'Production MySQL reporting database',
      location: 'Calgary, Canada',
      adminContact: 'sqladmin@example.com',
      isActive: true,
    },
  });

  const oracleServer = await prisma.server.create({
    data: {
      name: 'PROD-ORA-001',
      host: 'oracle.prod.example.com',
      port: 1521,
      rdbmsType: 'ORACLE',
      purpose: 'Production Oracle ERP system',
      location: 'Montreal, Canada',
      adminContact: 'oradmin@example.com',
      isActive: false,
      description: 'Legacy Oracle database - being migrated to PostgreSQL',
    },
  });


  // 3. Create Databases
  console.log('📦 Creating databases...');

  const informixDB = await prisma.database.create({
    data: {
      serverId: informixServer.id,
      name: 'dbschema1',
      purpose: 'Core business data warehouse',
      description: 'Primary Informix database containing historical business data',
      isActive: true,
    },
  });

  const postgresDB = await prisma.database.create({
    data: {
      serverId: postgresServer.id,
      name: 'app_db',
      purpose: 'Application primary database',
      description: 'Main database for application storage and processing',
      isActive: true,
    },
  });

  const mysqlDB = await prisma.database.create({
    data: {
      serverId: mysqlServer.id,
      name: 'reports_db',
      purpose: 'Reporting and analytics',
      description: 'Database used for generating business reports and analytics',
      isActive: true,
    },
  });

  const oracleDB = await prisma.database.create({
    data: {
      serverId: oracleServer.id,
      name: 'erp_prod',
      purpose: 'ERP system database',
      description: 'Legacy Oracle ERP production database',
      isActive: false,
    },
  });

  console.log(`✅ Created ${4} databases`);

  // 4. Create Tables
  console.log('📋 Creating tables...');

  const customerTable = await prisma.table.create({
    data: {
      databaseId: informixDB.id,
      name: 'customer',
      tableType: 'TABLE',
      description: 'Customer master data',
      rowCount: 125000,
      isActive: true,
    },
  });

  const orderTable = await prisma.table.create({
    data: {
      databaseId: informixDB.id,
      name: 'orders',
      tableType: 'TABLE',
      description: 'Customer orders history',
      rowCount: 2500000,
      isActive: true,
    },
  });

  const userAccountTable = await prisma.table.create({
    data: {
      databaseId: postgresDB.id,
      name: 'user_accounts',
      tableType: 'TABLE',
      description: 'User account information',
      rowCount: 85000,
      isActive: true,
    },
  });

  const productTable = await prisma.table.create({
    data: {
      databaseId: postgresDB.id,
      name: 'products',
      tableType: 'TABLE',
      description: 'Product catalog',
      rowCount: 42000,
      isActive: true,
    },
  });

  const orderSummaryView = await prisma.table.create({
    data: {
      databaseId: mysqlDB.id,
      name: 'vw_order_summary',
      tableType: 'VIEW',
      description: 'Order summary view for reporting',
      isActive: true,
    },
  });

  const customerReportView = await prisma.table.create({
    data: {
      databaseId: mysqlDB.id,
      name: 'vw_customer_report',
      tableType: 'VIEW',
      description: 'Customer information report view',
      isActive: true,
    },
  });

  const inventoryMV = await prisma.table.create({
    data: {
      databaseId: mysqlDB.id,
      name: 'mv_inventory_summary',
      tableType: 'MATERIALIZED_VIEW',
      description: 'Inventory summary materialized view',
      rowCount: 42000,
      isActive: true,
    },
  });

  console.log(`✅ Created ${7} tables`);

  // 5. Create Elements (Columns)
  console.log('🏷️  Creating elements/columns...');

  // Customer table elements
  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'customer_id',
      dataType: 'BIGINT',
      position: 1,
      isPrimaryKey: true,
      isNullable: false,
      description: 'Unique customer identifier',
    },
  });

  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'cust_name',
      dataType: 'VARCHAR',
      length: 150,
      position: 2,
      isNullable: false,
      description: 'Customer name',
    },
  });

  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'email',
      dataType: 'VARCHAR',
      length: 100,
      position: 3,
      isNullable: true,
      description: 'Customer email address',
    },
  });

  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'phone',
      dataType: 'VARCHAR',
      length: 20,
      position: 4,
      isNullable: true,
      description: 'Customer phone number',
    },
  });

  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'country_code',
      dataType: 'CHAR',
      length: 2,
      position: 5,
      isNullable: true,
      description: 'ISO country code',
    },
  });

  await prisma.element.create({
    data: {
      tableId: customerTable.id,
      name: 'create_date',
      dataType: 'DATE',
      position: 6,
      isNullable: false,
      defaultValue: 'CURRENT_DATE',
      description: 'Customer creation date',
    },
  });

  // Orders table elements
  await prisma.element.create({
    data: {
      tableId: orderTable.id,
      name: 'order_id',
      dataType: 'BIGINT',
      position: 1,
      isPrimaryKey: true,
      isNullable: false,
      description: 'Unique order identifier',
    },
  });

  await prisma.element.create({
    data: {
      tableId: orderTable.id,
      name: 'customer_id',
      dataType: 'BIGINT',
      position: 2,
      isForeignKey: true,
      isNullable: false,
      description: 'Reference to customer table',
    },
  });

  await prisma.element.create({
    data: {
      tableId: orderTable.id,
      name: 'order_date',
      dataType: 'TIMESTAMP',
      position: 3,
      isNullable: false,
      defaultValue: 'CURRENT_TIMESTAMP',
      description: 'Order timestamp',
    },
  });

  await prisma.element.create({
    data: {
      tableId: orderTable.id,
      name: 'total_amount',
      dataType: 'DECIMAL',
      precision: 15,
      scale: 2,
      position: 4,
      isNullable: false,
      description: 'Total order amount',
    },
  });

  await prisma.element.create({
    data: {
      tableId: orderTable.id,
      name: 'status',
      dataType: 'VARCHAR',
      length: 20,
      position: 5,
      isNullable: false,
      defaultValue: "'PENDING'",
      description: 'Order status (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)',
    },
  });

  // User accounts table elements
  await prisma.element.create({
    data: {
      tableId: userAccountTable.id,
      name: 'user_id',
      dataType: 'BIGINT',
      position: 1,
      isPrimaryKey: true,
      isNullable: false,
      description: 'Unique user identifier',
    },
  });

  await prisma.element.create({
    data: {
      tableId: userAccountTable.id,
      name: 'username',
      dataType: 'VARCHAR',
      length: 50,
      position: 2,
      isNullable: false,
      description: 'Unique username',
    },
  });

  await prisma.element.create({
    data: {
      tableId: userAccountTable.id,
      name: 'password_hash',
      dataType: 'VARCHAR',
      length: 255,
      position: 3,
      isNullable: false,
      description: 'Bcrypt hashed password',
    },
  });

  await prisma.element.create({
    data: {
      tableId: userAccountTable.id,
      name: 'is_active',
      dataType: 'BOOLEAN',
      position: 4,
      isNullable: false,
      defaultValue: 'true',
      description: 'Account active status',
    },
  });

  // Products table elements
  await prisma.element.create({
    data: {
      tableId: productTable.id,
      name: 'product_id',
      dataType: 'BIGINT',
      position: 1,
      isPrimaryKey: true,
      isNullable: false,
      description: 'Unique product identifier',
    },
  });

  await prisma.element.create({
    data: {
      tableId: productTable.id,
      name: 'product_code',
      dataType: 'VARCHAR',
      length: 50,
      position: 2,
      isNullable: false,
      description: 'Product SKU code',
    },
  });

  await prisma.element.create({
    data: {
      tableId: productTable.id,
      name: 'product_name',
      dataType: 'VARCHAR',
      length: 200,
      position: 3,
      isNullable: false,
      description: 'Product name',
    },
  });

  await prisma.element.create({
    data: {
      tableId: productTable.id,
      name: 'price',
      dataType: 'DECIMAL',
      precision: 10,
      scale: 2,
      position: 4,
      isNullable: false,
      description: 'Product price',
    },
  });

  await prisma.element.create({
    data: {
      tableId: productTable.id,
      name: 'inventory_count',
      dataType: 'INTEGER',
      position: 5,
      isNullable: false,
      defaultValue: '0',
      description: 'Current inventory count',
    },
  });

  console.log(`✅ Created ${23} elements/columns`);

  // 6. Create Abbreviations
  console.log('📚 Creating abbreviations...');

  const abbreviations = [
    {
      abbreviation: 'cust',
      sourceWord: 'customer',
      primeClass: 'NOUN',
      category: 'Business',
      definition: 'A person or organization that purchases goods or services',
    },
    {
      abbreviation: 'prod',
      sourceWord: 'product',
      primeClass: 'NOUN',
      category: 'Business',
      definition: 'A good or service offered for sale',
    },
    {
      abbreviation: 'ord',
      sourceWord: 'order',
      primeClass: 'NOUN',
      category: 'Business',
      definition: 'A request from a customer to purchase goods',
    },
    {
      abbreviation: 'amt',
      sourceWord: 'amount',
      primeClass: 'NOUN',
      category: 'Finance',
      definition: 'A quantity of something, typically money',
    },
    {
      abbreviation: 'id',
      sourceWord: 'identifier',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'A unique value used to identify an entity',
      isPrimeClass: true,
    },
    {
      abbreviation: 'num',
      sourceWord: 'number',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'A numeric value',
    },
    {
      abbreviation: 'desc',
      sourceWord: 'description',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'Text explaining or describing something',
    },
    {
      abbreviation: 'ts',
      sourceWord: 'timestamp',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'A date and time value',
      isPrimeClass: true,
    },
    {
      abbreviation: 'fk',
      sourceWord: 'foreign key',
      primeClass: 'NOUN',
      category: 'Database',
      definition: 'A database field that links to another table',
      isPrimeClass: true,
    },
    {
      abbreviation: 'pk',
      sourceWord: 'primary key',
      primeClass: 'NOUN',
      category: 'Database',
      definition: 'A unique identifier for database records',
      isPrimeClass: true,
    },
    {
      abbreviation: 'db',
      sourceWord: 'database',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'A collection of organized data',
      isPrimeClass: true,
    },
    {
      abbreviation: 'tbl',
      sourceWord: 'table',
      primeClass: 'NOUN',
      category: 'Database',
      definition: 'A database object with rows and columns',
    },
    {
      abbreviation: 'col',
      sourceWord: 'column',
      primeClass: 'NOUN',
      category: 'Database',
      definition: 'A vertical array of data in a table',
    },
    {
      abbreviation: 'val',
      sourceWord: 'value',
      primeClass: 'NOUN',
      category: 'Technical',
      definition: 'The data content of a field',
    },
  ];

  await Promise.all(
    abbreviations.map(abbr =>
      prisma.abbreviation.create({
        data: abbr,
      })
    )
  );

  console.log(`✅ Created ${abbreviations.length} abbreviations`);

  // 7. Create Audit Logs
  console.log('📝 Creating audit logs...');

  const auditEntries = [
    {
      entityType: 'USER',
      entityId: admin.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ role: 'ADMIN', email: admin.email }),
    },
    {
      entityType: 'USER',
      entityId: editor.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ role: 'EDITOR', email: editor.email }),
    },
    {
      entityType: 'USER',
      entityId: viewer.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ role: 'VIEWER', email: viewer.email }),
    },
    {
      entityType: 'SERVER',
      entityId: informixServer.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ name: informixServer.name, rdbmsType: 'INFORMIX' }),
    },
    {
      entityType: 'SERVER',
      entityId: postgresServer.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ name: postgresServer.name, rdbmsType: 'POSTGRESQL' }),
    },
    {
      entityType: 'DATABASE',
      entityId: informixDB.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ name: informixDB.name, serverId: informixServer.id }),
    },
    {
      entityType: 'TABLE',
      entityId: customerTable.id,
      action: 'CREATE',
      userId: admin.id,
      changes: JSON.stringify({ name: customerTable.name, rowCount: 125000 }),
    },
  ];

  await Promise.all(
    auditEntries.map(entry =>
      prisma.auditLog.create({
        data: entry,
      })
    )
  );

  console.log(`✅ Created ${auditEntries.length} audit logs`);

  console.log('✨ Database seed completed successfully!');
  console.log('\n📋 Test Credentials:');
  console.log('  Admin:   admin@schemajeli.com / Admin@123');
  console.log('  Editor:  editor@schemajeli.com / Editor@123');
  console.log('  Viewer:  viewer@schemajeli.com / Viewer@123');
}

main()
  .catch(error => {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
