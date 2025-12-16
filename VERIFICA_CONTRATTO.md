# Verifica del Contratto su Polygonscan

## Informazioni Contratto

- **Indirizzo**: `0x123d3371C3481394a6BddfDFB85BE31D6C182cEE`
- **Network**: Amoy (Polygon Testnet)
- **Polygonscan**: https://amoy.polygonscan.com/address/0x123d3371C3481394a6BddfDFB85BE31D6C182cEE

## Verifica Manuale su Polygonscan

1. Vai su https://amoy.polygonscan.com/address/0x123d3371C3481394a6BddfDFB85BE31D6C182cEE
2. Clicca su "Contract" tab
3. Clicca su "Verify and Publish"
4. Compila i seguenti dati:
   - **Compiler Type**: Solidity (Single file)
   - **Compiler Version**: v0.8.25+commit.c61f9f52
   - **EVM Version**: Cancun
   - **License**: MIT
   - **Optimization**: Yes (200 runs)
   - **Constructor Arguments**: 
     ```
     0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000173344205072696e74204e465420436f6c6c656374696f6e00000000000000000000000000000000000000000000000000000000000000000000000000000000063344504e46540000000000000000000000000000000000000000000000000000
     ```
   - **Contract Code**: Incolla il contenuto di `src/ThreeDNFT.sol`

## Verifica Automatica con Foundry

Se hai configurato `AMOY_ETHERSCAN_API_KEY` nel file `.env`:

```bash
forge verify-contract \
  0x123d3371C3481394a6BddfDFB85BE31D6C182cEE \
  src/ThreeDNFT.sol:ThreeDNFT \
  --chain-id 80002 \
  --constructor-args $(cast abi-encode "constructor(string,string)" "3D Print NFT Collection" "3DPNFT") \
  --etherscan-api-key $AMOY_ETHERSCAN_API_KEY \
  --watch
```

## Note

Il contratto è già deployato e funzionante. La verifica su Polygonscan permette di:
- Visualizzare il codice sorgente direttamente su Polygonscan
- Interagire con il contratto tramite l'interfaccia web
- Verificare la sicurezza e l'autenticità del codice

