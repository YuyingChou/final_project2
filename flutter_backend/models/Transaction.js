const mongoose = require('mongoose');
const Grid = require('gridfs-stream');
const conn = mongoose.connection;
Grid.mongo = mongoose.mongo;

const TransactionSchema = new mongoose.Schema({
    transactionname: {
        type: String,
        required: true,
        min: 1,
        max: 100,
    },
    category: {
        type: String,
        required: true,
        enum: ["書籍", "生活用品","電子產品","其他"],
      },
    image: {
        type: Buffer,
    },
    quantity: {
        type: Number,
        required: true,
    },
    price: {
        type: Number,
        required: true,
        min: 1,
        max: 100000,
    },
    description: {
        type: String,
        required: true,
        min: 1,
        max: 10000,
    },
    contact: {
        type: String,
        required: true,
        max: 10000,
    },
    place: {
        type: String,
        required: true,
        max: 10000,
    },
    seller: {
        type: String,
        required: true,
    },
    sellerid: {
        type: String,
        required: true,
    },
    status: {
        type: Number,
        required: true,
    },
},{ timestamps: true }
); 

module.exports = mongoose.model("Transaction", TransactionSchema);