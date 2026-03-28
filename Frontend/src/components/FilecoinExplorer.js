// src/components/FilecoinExplorer.js
import React, { useState } from 'react';
import axios from 'axios';
import { File, CheckCircle } from 'lucide-react';

function FilecoinExplorer({ cid }) {
  const [status, setStatus] = useState('unknown');

  const verifyCID = async () => {
    try {
      const res = await axios.get(`https://api.filecoin.io/api/v1/chain/getBlock/${cid}`);
      setStatus('verified');
    } catch {
      setStatus('invalid');
    }
  };

  return (
    <div className="bg-green-900/30 border border-green-500 p-4 rounded-lg flex items-center gap-3">
      <File className="w-5 h-5" />
      <div>
        CID: <code className="bg-black px-2 py-1 rounded text-xs">{cid}</code>
        <button onClick={verifyCID} className="ml-2 text-xs bg-green-600 px-3 py-1 rounded">Verify</button>
        {status === 'verified' && <CheckCircle className="w-5 h-5 text-green-400 ml-2" />}
      </div>
    </div>
  );
}

export default FilecoinExplorer;
