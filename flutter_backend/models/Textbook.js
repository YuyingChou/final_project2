const mongoose = require('mongoose');


const TextbookSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        min: 1,
        max: 10000,
    },
    isbn: {
        type: String, 
        required: true,
      },
    quantity: {
        type: Number,
        required: true,
        min: 0,
        max: 100,
    },
    price: {
        type: Number,
    },
    organizer: {
        type: String,
        required: true,
    },
    organizerid: {
        type: String,
        required: true,
    },
    place: {
        type: String,
        required: true,
        max: 10000,
    },
    phone: {
        type: String,
        required: true,
    },
    status:{
        type: Number,
        required:true,
    },
    closingtime:{
        type: Date,
        required:true,
    },
    booksellerreceivedtime:{
        type: Date,
    },
    describe: {
        type: String,
        required: true,
    },
    bookseller: {
        type: String,
    },
    booksellerphone: {
        type: String,
    },
    bookwillarrivaltime: {
        type: String,
    },
    getbookstatus:{
        type: Number,
        required:true,
    },
    bookarrivaltime: {
        type: String,
    },
},{ timestamps: true }
); 

module.exports = mongoose.model("Textbook", TextbookSchema);