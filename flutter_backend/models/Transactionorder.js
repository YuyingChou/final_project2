const mongoose = require('mongoose');

const TransactionorderSchema = new mongoose.Schema({
    buyer: {
        type: String,
        required: true,
    },
    buyerid: {
        type: String,
        required: true,
    },
    seller: {
        type: String,
        required: true,
    },
    sellerid: {
        type: String,
        required: true,
    },
    transactionid: {
        type: String,
        required: true,
      },
    time: {
        type: String,
        required: true,
    },
    quantity: {
        type: Number,
        required: true,
        min: 1,
        max: 100,
    },
    sum: {
        type: Number,
        required: true,
        min: 1,
        max: 100000,
    },
    notes: {
        type: String,
    },
    buyerphone:{
        type: String,
        required: true,
    },
    sellerphone:{
        type: String,
        required: true,
    }
},{ timestamps: true }
); 

module.exports = mongoose.model("Transactionorder", TransactionorderSchema);