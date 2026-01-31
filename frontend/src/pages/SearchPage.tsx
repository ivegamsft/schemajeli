import { useState } from 'react';
import { Search, Database, Table, BookOpen } from 'lucide-react';
import { searchService, SearchResults } from '../services/searchService';
import { toast } from 'sonner';

export default function SearchPage() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResults | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) {
      toast.error('Please enter a search query');
      return;
    }

    try {
      setLoading(true);
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

      {/* Results */}
      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Searching...</p>
        </div>
      ) : results ? (
        <div className="space-y-6">
          {/* Summary */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <p className="text-sm text-blue-900">
              Found {results.totalResults} results for "<strong>{query}</strong>"
            </p>
          </div>

          {/* Tables */}
          {results.tables.length > 0 && (
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center gap-2">
                  <Table className="w-5 h-5 text-gray-600" />
                  <h2 className="text-lg font-semibold text-gray-900">
                    Tables ({results.tables.length})
                  </h2>
                </div>
              </div>
              <div className="divide-y divide-gray-200">
                {results.tables.map((table) => (
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
          {results.elements.length > 0 && (
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center gap-2">
                  <Database className="w-5 h-5 text-gray-600" />
                  <h2 className="text-lg font-semibold text-gray-900">
                    Columns ({results.elements.length})
                  </h2>
                </div>
              </div>
              <div className="divide-y divide-gray-200">
                {results.elements.map((element) => (
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
          {results.abbreviations.length > 0 && (
            <div className="bg-white rounded-lg shadow">
              <div className="px-6 py-4 border-b border-gray-200">
                <div className="flex items-center gap-2">
                  <BookOpen className="w-5 h-5 text-gray-600" />
                  <h2 className="text-lg font-semibold text-gray-900">
                    Abbreviations ({results.abbreviations.length})
                  </h2>
                </div>
              </div>
              <div className="divide-y divide-gray-200">
                {results.abbreviations.map((abbr) => (
                  <div key={abbr.id} className="px-6 py-4 hover:bg-gray-50">
                    <div className="flex items-start gap-4">
                      <span className="font-mono text-sm font-semibold text-primary-600">
                        {abbr.abbreviation}
                      </span>
                      <div className="flex-1">
                        <p className="text-sm text-gray-900">{abbr.fullName}</p>
                        {abbr.description && (
                          <p className="text-xs text-gray-600 mt-1">{abbr.description}</p>
                        )}
                        {abbr.category && (
                          <span className="text-xs px-2 py-1 bg-gray-100 text-gray-700 rounded mt-1 inline-block">
                            {abbr.category}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* No Results */}
          {results.totalResults === 0 && (
            <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
              <Search className="w-12 h-12 mx-auto text-gray-400" />
              <p className="mt-2 text-gray-600">No results found for "{query}"</p>
              <p className="text-sm text-gray-500 mt-1">Try different search terms</p>
            </div>
          )}
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
