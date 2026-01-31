/**
 * Export data to CSV format
 */
export function exportToCSV(data: any[], filename: string) {
  if (data.length === 0) {
    throw new Error('No data to export');
  }

  // Get headers from first object
  const headers = Object.keys(data[0]);
  
  // Create CSV content
  const csvContent = [
    headers.join(','), // Header row
    ...data.map(row => 
      headers.map(header => {
        const value = row[header];
        // Handle values with commas, quotes, or newlines
        if (value === null || value === undefined) return '';
        const stringValue = String(value);
        if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
          return `"${stringValue.replace(/"/g, '""')}"`;
        }
        return stringValue;
      }).join(',')
    )
  ].join('\n');

  // Create blob and download
  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
  downloadBlob(blob, `${filename}.csv`);
}

/**
 * Export data to JSON format
 */
export function exportToJSON(data: any, filename: string) {
  const jsonContent = JSON.stringify(data, null, 2);
  const blob = new Blob([jsonContent], { type: 'application/json;charset=utf-8;' });
  downloadBlob(blob, `${filename}.json`);
}

/**
 * Download blob as file
 */
function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}

/**
 * Flatten nested objects for CSV export
 */
export function flattenObject(obj: any, prefix = ''): any {
  const flattened: any = {};
  
  Object.keys(obj).forEach(key => {
    const value = obj[key];
    const newKey = prefix ? `${prefix}.${key}` : key;
    
    if (value === null || value === undefined) {
      flattened[newKey] = '';
    } else if (typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
      // Recursively flatten nested objects
      Object.assign(flattened, flattenObject(value, newKey));
    } else if (Array.isArray(value)) {
      // Convert arrays to comma-separated strings
      flattened[newKey] = value.join('; ');
    } else if (value instanceof Date) {
      flattened[newKey] = value.toISOString();
    } else {
      flattened[newKey] = value;
    }
  });
  
  return flattened;
}

/**
 * Export table data with columns to structured format
 */
export function exportTableWithColumns(table: any, elements: any[], format: 'csv' | 'json') {
  const filename = `table_${table.name}_${new Date().toISOString().split('T')[0]}`;
  
  if (format === 'json') {
    const exportData = {
      table: {
        name: table.name,
        type: table.tableType,
        description: table.description,
        database: table.database?.name,
      },
      columns: elements.map(el => ({
        name: el.name,
        dataType: el.dataType,
        length: el.length,
        precision: el.precision,
        scale: el.scale,
        isPrimaryKey: el.isPrimaryKey,
        isForeignKey: el.isForeignKey,
        description: el.description,
      })),
    };
    exportToJSON(exportData, filename);
  } else {
    const flatData = elements.map(el => ({
      table_name: table.name,
      table_type: table.tableType,
      column_name: el.name,
      data_type: el.dataType,
      length: el.length || '',
      precision: el.precision || '',
      scale: el.scale || '',
      is_primary_key: el.isPrimaryKey ? 'Yes' : 'No',
      is_foreign_key: el.isForeignKey ? 'Yes' : 'No',
      description: el.description || '',
    }));
    exportToCSV(flatData, filename);
  }
}
