import { useState, useMemo } from 'react';
import { Search, Database, Table, BookOpen, X } from 'lucide-react';
import { searchService, SearchResults } from '../services/searchService';
import { toast } from 'sonner';

type EntityType = 'all' | 'tables' | 'elements' | 'abbreviations';
type DataType = 'all' | string;

export default function SearchPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResults | null>(null);
  const [loading, setLoading] = useState(false);
  const [entityTypeFilter, setEntityTypeFilter] = useState<EntityType>('all');
  const [dataTypeFilter, setDataTypeFilter] = useState<DataType>('all');

  // Get unique data types from results
  const dataTypes = useMemo(() => {
    if (!results) return [];
    const types = new Set(results.elements.map((e) => e.dataType));
    return Array.from(types).sort();
  }, [results]);

  // Filter results based on selections
  const filteredResults = useMemo(() => {
    if (!results) return null;

    let tables = results.tables;
    let elements = results.elements;
    let abbreviations = results.abbreviations;

    if (entityTypeFilter !== 'all') {
      tables = entityTypeFilter === 'tables' ? tables : [];
      elements = entityTypeFilter === 'elements' ? elements : [];
      abbreviations = entityTypeFilter === 'abbreviations' ? abbreviations : [];
    }

    if (dataTypeFilter !== 'all') {
      elements = elements.filter((e) => e.dataType === dataTypeFilter);
    }

    return {
      tables,
      elements,
      abbreviations,
      totalResults: tables.length + elements.length + abbreviations.length,
    };
  }, [results, entityTypeFilter, dataTypeFilter]);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) {
      toast.error('Please enter a search query');
      return;
    }

    try {
      setLoading(true);
      setEntityTypeFilter('all');
      setDataTypeFilter('all');
      const data = await searchService.search(query);
      setResults(data);
    } catch (error) {
      toast.error('Search failed');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Search Schema</h1>
        <p className="text-gray-600 mt-1">
          Search across servers, databases, tables, columns, and abbreviations
        </p>
      </div>

      {/* Search Form */}
      <form onSubmit={handleSearch} className="mb-6">
        <div className="flex gap-2">
          <div className="flex-1 relative">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search for tables, columns, abbreviations..."
              className="w-full px-4 py-3 pl-12 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
            <Search className="absolute left-4 top-3.5 w-5 h-5 text-gray-400" />
          </div>
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-3 bg-primary-500 text-white rounded-lg hover:bg-primary-600 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Searching...' : 'Search'}
          </button>
        </div>
      </form>

      {/* Results with Filters */}
      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Searching...</p>
        </div>
      ) : results ? (
        <div className="grid grid-cols-4 gap-6">
          {/* Filters Sidebar */}
          <div className="col-span-1">
            <div className="sticky top-8 space-y-6">
              {/* Entity Type Filter */}
              <div className="bg-white rounded-lg shadow p-4">
                <h3 className="text-sm font-semibold text-gray-900 mb-3">Entity Type</h3>
                <div className="space-y-2">
                  {[
                    { value: 'all' as EntityType, label: 'All' },
                    { value: 'tables' as EntityType, label: `Tables (${results.tables.length})` },
                    { value: 'elements' as EntityType, label: `Columns (${results.elements.length})` },
                    { value: 'abbreviations' as EntityType, label: `Abbreviations (${results.abbreviations.length})` },
                  ].map((option) => (
                    <label key={option.value} className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="radio"
                        name="entityType"
                        value={option.value}
                        checked={entityTypeFilter === option.value}
                        onChange={(e) => setEntityTypeFilter(e.target.value as EntityType)}
                        className="w-4 h-4"
                      />
                      <span className="text-sm text-gray-700">{option.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Data Type Filter */}
              {dataTypes.length > 0 && (
                <div className="bg-white rounded-lg shadow p-4">
                  <h3 className="text-sm font-semibold text-gray-900 mb-3">Data Type</h3>
                  <select
                    value={dataTypeFilter}
                    onChange={(e) => setDataTypeFilter(e.target.value as DataType)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                  >
                    <option value="all">All Types</option>
                    {dataTypes.map((type) => (
                      <option key={type} value={type}>
                        {type}
                      </option>
                    ))}
                  </select>
                </div>
              )}

              {/* Clear Filters */}
              {(entityTypeFilter !== 'all' || dataTypeFilter !== 'all') && (
                <button
                  onClick={() => {
                    setEntityTypeFilter('all');
                    setDataTypeFilter('all');
                  }}
                  className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm text-primary-600 hover:text-primary-700 border border-primary-200 rounded-lg hover:bg-primary-50"
                >
                  <X className="w-4 h-4" />
                  Clear Filters
                </button>
              )}
            </div>
          </div>

          {/* Results */}
          <div className="col-span-3 space-y-6">
            {/* Summary */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <p className="text-sm text-blue-900">
                Found {filteredResults?.totalResults || 0} result{((filteredResults?.totalResults || 0) !== 1 ? 's' : '')} for "<strong>{query}</strong>"
              </p>
            </div>

            {/* Tables */}
            {filteredResults?.tables.length > 0 && (
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <div className="flex items-center gap-2">
                    <Table className="w-5 h-5 text-gray-600" />
                    <h2 className="text-lg font-semibold text-gray-900">
                      Tables ({filteredResults.tables.length})
                    </h2>
                  </div>
                </div>
                <div className="divide-y divide-gray-200">
                  {filteredResults.tables.map((table) => (
                    <div key={table.id} className="px-6 py-4 hover:bg-gray-50">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-medium text-gray-900">{table.name}</h3>
                          {table.description && (
                            <p className="text-sm text-gray-600 mt-1">{table.description}</p>
                          )}
                          <div className="flex items-center gap-2 mt-2">
                            <span className="text-xs px-2 py-1 bg-purple-100 text-purple-800 rounded">
                              {table.tableType}
                            </span>
                            <span className="text-xs text-gray-500">
                              {table._count?.elements || 0} columns
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Elements/Columns */}
            {filteredResults?.elements.length > 0 && (
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <div className="flex items-center gap-2">
                    <Database className="w-5 h-5 text-gray-600" />
                    <h2 className="text-lg font-semibold text-gray-900">
                      Columns ({filteredResults.elements.length})
                    </h2>
                  </div>
                </div>
                <div className="divide-y divide-gray-200">
                  {filteredResults.elements.map((element) => (
                    <div key={element.id} className="px-6 py-4 hover:bg-gray-50">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-medium text-gray-900">{element.name}</h3>
                          {element.description && (
                            <p className="text-sm text-gray-600 mt-1">{element.description}</p>
                          )}
                          <div className="flex items-center gap-2 mt-2">
                            <span className="text-xs px-2 py-1 bg-green-100 text-green-800 rounded">
                              {element.dataType}
                            </span>
                            {element.isPrimaryKey && (
                              <span className="text-xs px-2 py-1 bg-yellow-100 text-yellow-800 rounded">
                                PK
                              </span>
                            )}
                            {element.isForeignKey && (
                              <span className="text-xs px-2 py-1 bg-blue-100 text-blue-800 rounded">
                                FK
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Abbreviations */}
            {filteredResults?.abbreviations.length > 0 && (
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200">
                  <div className="flex items-center gap-2">
                    <BookOpen className="w-5 h-5 text-gray-600" />
                    <h2 className="text-lg font-semibold text-gray-900">
                      Abbreviations ({filteredResults.abbreviations.length})
                    </h2>
                  </div>
                </div>
                <div className="divide-y divide-gray-200">
                  {filteredResults.abbreviations.map((abbr) => (
                    <div key={abbr.id} className="px-6 py-4 hover:bg-gray-50">
                      <div className="flex items-start gap-4">
                        <span className="font-mono text-sm font-semibold text-primary-600">
                          {abbr.abbreviation}
                        </span>
                        <div className="flex-1">
                          <p className="text-sm text-gray-900">{abbr.meaning}</p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* No Results */}
            {filteredResults?.totalResults === 0 && (
              <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
                <Search className="w-12 h-12 mx-auto text-gray-400" />
                <p className="mt-2 text-gray-600">No results found with current filters</p>
                <p className="text-sm text-gray-500 mt-1">Try adjusting your filters or search terms</p>
              </div>
            )}
          </div>
        </div>
      ) : (
        <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
          <Search className="w-12 h-12 mx-auto text-gray-400" />
          <p className="mt-2 text-gray-600">Enter a search query to get started</p>
          <p className="text-sm text-gray-500 mt-1">
            Search for tables, columns, or abbreviations
          </p>
        </div>
      )}
    </div>
  );
}
