const LitJsSdk = require("lit-js-sdk/build/index.node.js");
const { fromString } = require("uint8arrays/from-string");
const ethers = require("ethers");
const siwe = require("siwe");
const tokenabi = require('./token.json');
require('dotenv').config({ path: ".env" });

// this code act as event listening solution for Lit Action
// whenever a event takes place either on or off chain
// the solution in its current state; triggers Lit action to sign the
// transaction and then can be used by developers to perform other tasks


async function main() {
    // address where the contract is deployed
    const tokenAddress = '0x3287fE76393823cF5e444322598BE659c7881cA6';

    // Private key of wallet
    const PRIVATE_KEY = process.env.PRIVATE_KEY;

    // connecting to a network by providing RPC Provider, in case of using Alchemy or Infura WebSocketProvider will be used
    const provider = new ethers.providers.JsonRpcProvider('https://preseed-testnet-1.roburna.com/');

    // connecting wallet with provider
    const signer = new ethers.Wallet(PRIVATE_KEY, provider);

    // connecting wallet, provider and contract for read only mode
    const contract = new ethers.Contract(tokenAddress, tokenabi, signer);

    // all methods will be executed after transfer event is triggered in the contract
    //listening to transfer event
    contract.on('Transfer', async (from, to, value, event) => {
        let info = {
            from: from,
            to: to,
            value: value.toString(), // decimals according to token
            data: event, //all additional details i.e., blockheight, txnHash etc.
        };

        // printing the transfer event triggered from the transaction with all its params
        console.log(JSON.stringify(info, null, 4));

        // defining condition when a user send funds to contract the transfer transaction and LIT actions to sign a message will be executed 
        if (info.to == tokenAddress && info.value >= 1) {

            //getting address of sender
            sender = info.from;
            console.log('This is sender address: ' + sender);

            //connecting with the contract to carry out write mode
            const signerConnect = contract.connect(signer);

            // Parsing tokens according to their decimal 
            const Tkn = ethers.utils.parseEther("10.0", 18);

            // trigerring transfer function as a result of transfer event
            tknTransfer = await signerConnect.transfer(sender, Tkn);
            console.log('This is the current transfer details: 👇');
            console.log(tknTransfer);

            // Requesting signature share from the Lit Node 
            const litActionCode = `const signTxn = async () => {
                const signMessage = await Lit.Actions.signEcdsa({ toSign, publicKey, sigName });
                };
            signTxn();
            `;

            // passing params, connecting to node and executing the function
            const runLitAction = async () => {

                // pkp public-pvt key pair
                const pkpid = '04388651794e3b6a2a8a38b66f1606410a9d679efa092acb2aeb804532698be16dbe8ab0c5880891890b1fd8db1db0c9be9ca8b107bf43d1962dc067cad0d3e21c';

                //converting Private key hash into uintarray8
                const privKeyBuffer = fromString(PRIVATE_KEY, "base16");

                // deriving wallet 
                const wallet = new ethers.Wallet(privKeyBuffer);

                // defining message to be signed from specific network; needs to be supported by Lit Protocol
                const domain = "Polygon Mumbai";
                const origin = "https://rpc-mumbai.matic.today";

                //converting the txn object into string
                const txnString = JSON.stringify(tknTransfer);

                // message to be signed
                const txnMessage = ('You have successfully become member of Lit Dao');

                // authenticate by signing a message for event triggered on off-chain network 
                const signTxn = new siwe.SiweMessage({
                    domain,
                    address: wallet.address,
                    txnMessage,
                    uri: origin,
                    version: "1",
                    chainId: "80001",
                });

                // preparing the message to be signed
                const txnToSign = signTxn.prepareMessage();

                //signing the message with wallet
                const signature = await wallet.signMessage(txnToSign);

                console.log("This is the signed message: ", signature);

                // verifying the message signed from the wallet
                const recoveredAddress = ethers.utils.verifyMessage(txnToSign, signature);

                //  initialising the Lit node
                const litNodeClient = new LitJsSdk.LitNodeClient({
                    litNetwork: "serrano",
                });

                // passing params for authSig to pass as JS params
                const authSig = {
                    sig: signature,
                    derivedVia: "web3.eth.personal.sign",
                    signedMessage: txnToSign,
                    address: recoveredAddress,
                };
                console.log("This is authSig: ", authSig);

                await litNodeClient.connect();

                // passing params to carry out Lit action of signing a message using pkp
                try {
                    const txnSign = await litNodeClient.executeJs({
                        code: litActionCode,
                        authSig,
                        jsParams: {
                            toSign: txnString,
                            publicKey: pkpid,
                            sigName: 'Team Lit Protocol'
                        },
                    });

                    //prinitng the signature output
                    console.log("This is the signed transaction: 👇");
                    console.log(txnSign);
                }
                //catching error
                catch (e) {
                    console.log(e);
                }
            };
            runLitAction();
        }
    });
}

main();