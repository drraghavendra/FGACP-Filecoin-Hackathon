// src/components/SpamDemo.js
import React, { useState } from 'react';
import { AlertTriangle, StopCircle } from 'lucide-react';

function SpamDemo({ onSpamBlocked }) {
  const [spamming, setSpamming] = useState(false);
  const [blocked, setBlocked] = useState(false);

  const startSpam = () => {
    setSpamming(true);
    setTimeout(() => {
      setSpamming(false);
      setBlocked(true);
      onSpamBlocked();
    }, 2000);
  };

  return (
    <div className="bg-red-900/50 border border-red-500 p-6 rounded-xl">
      <h3 className="text-xl mb-4 flex items-center gap-2"><AlertTriangle className="w-6 h-6" /> Spam Bot Demo</h3>
      {blocked ? (
        <div className="text-center p-4 bg-red-500/20 rounded">
          <StopCircle className="w-12 h-12 mx-auto mb-2" />
          <div>Spam Blocked! Stake Slashed 🚫</div>
        </div>
      ) : (
        <button onClick={startSpam} disabled={spamming} className="w-full bg-red-600 px-6 py-3 rounded-lg hover:bg-red-500 disabled:opacity-50">
          {spamming ? 'Spamming...' : 'Activate Spam Bot'}
        </button>
      )}
    </div>
  );
}

export default SpamDemo;
