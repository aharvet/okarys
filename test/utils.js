const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

function storageToUint(storage) {
  return parseInt(hex);
}

function storageToAddress(storage) {
  return `0x${storage.slice(-40)}`;
}

function storageToBool(storage) {
  const lastChar = storage.slice(-1);
  if (lastChar === '0') return false;
  else if (lastChar === '1') return true;
  else throw new Error('storageToBool: invalid input');
}

// Works up to 30 characters
function storageToString(storage) {
  const hex = storageToHex(storage);
  return hexToString(hex);
}

function storageToHex(storage) {
  const end = storage.indexOf('00');
  return storage.substr(2, end - 2, 16);
}

function hexToString(hex) {
  let string = '';
  for (let i = 0; i < hex.length; i += 2) {
    string += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
  }
  return string;
}

module.exports = {
  ZERO_ADDRESS,
  storageToUint,
  storageToAddress,
  storageToBool,
  storageToString,
};
