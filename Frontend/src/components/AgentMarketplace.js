// src/components/AgentMarketplace.js
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Search, Star } from 'lucide-react';

const API_BASE = 'http://localhost:8000';

function AgentMarketplace({ account, onSelectAgent }) {
  const [marketAgents, setMarketAgents] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    axios.get(`${API_BASE}/marketplace?cap=stock-analysis`).then(res => setMarketAgents(res.data));
  }, []);

  const filtered = marketAgents.filter(a => a.name.toLowerCase().includes(search.toLowerCase()));

  return (
    <div className="bg-gray-900 p-6 rounded-xl">
      <div className="flex gap-2 mb-4">
        <input
          value={search}
          onChange={e => setSearch(e.target.value)}
          placeholder="Search analysts..."
          className="flex-1 bg-gray-800 p-2 rounded text-black"
        />
        <Search className="w-5 h-5 mt-2" />
      </div>
      <div className="grid gap-3 max-h-96 overflow-y-auto">
        {filtered.map(agent => (
          <div key={agent.id} className="p-3 bg-gray-800 rounded flex justify-between items-center hover:bg-gray-700 cursor-pointer" onClick={() => onSelectAgent(agent)}>
            <div>
              <div className="font-bold">{agent.name}</div>
              <div className="text-sm opacity-75">{agent.capabilities.join(', ')}</div>
            </div>
            <div className="flex items-center gap-1">
              <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
              <span>{agent.reputation}</span>
              <span className="ml-2 text-sm text-green-400">{agent.price}/msg</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default AgentMarketplace;
