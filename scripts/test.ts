import {
	DEFAULT_ED25519_DERIVATION_PATH,
	Ed25519Keypair,
	JsonRpcProvider,
	RawSigner,
	devnetConnection,
	TransactionBlock,
    toB64,
    fromExportedKeypair
} from '@mysten/sui.js';

require('dotenv').config();

const MNEMONICS: string = process.env.MNEMONICS || '';
const PACKAGE_ID: string = process.env.PACKAGE_ID || '';
const ADMIN_CAP_ID: string = process.env.ADMIN_CAP_ID || '';
const CONFIG_ID: string = process.env.CONFIG_ID || '';
const CASE_COUNT_ID: string = process.env.CASE_COUNT_ID || '';

const CASE_1_ID: string = process.env.CASE_1_ID || '0x240c7f4fe449e79388c0bc2aad4c9baee92068b1c6f180caa81111fd506af578';
const CASE_2_ID: string = process.env.CASE_2_ID || '';

const new_admin = '0x64872720614e121f12f8f1abc3b2e2b081bf740d7cf8017cc77275f506305525';

const new_fee_account = '0x64872720614e121f12f8f1abc3b2e2b081bf740d7cf8017cc77275f506305525';

const provider = new JsonRpcProvider(devnetConnection);
// const keypair_ed25519 = Ed25519Keypair.deriveKeypair(
//     MNEMONICS,
//     DEFAULT_ED25519_DERIVATION_PATH
// );

const privkey = '0x5d1337db6186b4d577c9098fdef1aac46f8e85870631ee87a71739cd8ed0c6ba'
const privateKeyBytes = Uint8Array.from(Buffer.from(privkey.slice(2), "hex")); 

const keypair = fromExportedKeypair({
    schema: "ED25519",
    privateKey: toB64(privateKeyBytes),
});

const signer = new RawSigner(keypair, provider);

async function set_contract_admin() {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::config::set_contract_admin`,
            arguments: [
                tx.object(ADMIN_CAP_ID),
                tx.object(CONFIG_ID),
                tx.pure(new_admin)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function set_fee_account() {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::config::set_fee_account`,
            arguments: [
                tx.object(ADMIN_CAP_ID),
                tx.object(CONFIG_ID),
                tx.pure(new_fee_account)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function set_points_rate(rate: number) {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::config::set_points_rate`,
            arguments: [
                tx.object(ADMIN_CAP_ID),
                tx.object(CONFIG_ID),
                tx.pure(rate)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}


async function add_case(address: string) {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::vault::add_case`,
            arguments: [
                tx.object(ADMIN_CAP_ID),
                tx.object(CONFIG_ID),
                tx.object(CASE_COUNT_ID),
                tx.pure(address)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function deposit1() {
    try {
        const tx = new TransactionBlock();
        const [coin] = tx.splitCoins(tx.gas, [tx.pure(100000)]);
        await tx.moveCall({
            target: `${PACKAGE_ID}::vault::deposit`,
            arguments: [
                tx.object(CASE_1_ID),
                coin
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function deposit2() {
    try {
        const tx = new TransactionBlock();
        const [coin] = tx.splitCoins(tx.gas, [tx.pure(200000)]);
        await tx.moveCall({
            target: `${PACKAGE_ID}::vault::deposit`,
            arguments: [
                tx.object(CASE_2_ID),
                coin
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function pay_to_beneficiary1(amount: number) {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::vault::pay_to_beneficiary`,
            arguments: [
                tx.object(CASE_1_ID),
                tx.object(CONFIG_ID),
                tx.pure(amount)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function pay_to_beneficiary2(amount: number) {
    try {
        const tx = new TransactionBlock();
        await tx.moveCall({
            target: `${PACKAGE_ID}::vault::pay_to_beneficiary`,
            arguments: [
                tx.object(CASE_2_ID),
                tx.object(CONFIG_ID),
                tx.pure(amount)
            ],
        });

        const transaction = await signer.signAndExecuteTransactionBlock({
            transactionBlock: tx,
            options: {
                showInput: true,
                showEffects: true,
                showEvents: true,
                showObjectChanges: true,
            }
        });

        console.log(transaction);
    } catch (error) {
        console.log(error);
    }
}

async function main() {
    // await set_contract_admin();
    // await set_fee_account();
    // await set_points_rate(0);
    // await set_points_rate(1000);
    // await set_points_rate(10000);

    // await add_case('0x64872720614e121f12f8f1abc3b2e2b081bf740d7cf8017cc77275f506305525');
    // await add_case('0x3f43eb99214e9604a86b373f01b988cf6927ca282b414a28026a66e12d69810a');
    // await deposit1();
    // await deposit2();
    await pay_to_beneficiary1(90000);
    // await pay_to_beneficiary1(100);
    // await pay_to_beneficiary1(90000);
    // await pay_to_beneficiary1(10000);
    // await pay_to_beneficiary2(200000);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(`error: ${error.stack}`);
        process.exit(1);
    });

export default {deposit1}