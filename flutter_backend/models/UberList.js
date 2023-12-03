const mongoose = require('mongoose');

const UberListSchema = new mongoose.Schema({
    listId: {
        type: String,
    },
    userId :{
        type: String,
        required: true,
    },
    anotherUserId: {
        type: String,
    },
    reserved:{
        type: Boolean,
        required: true,
    },
    startingLocation: {
        type: String,
        required: true,
        max: 20,
    },
    destination:{
        type: String,
        required: true,
        max: 20,
    },
    selectedDateTime:{
        type: Date,
        required:true,
    },
    wantToFindRide:{
        type: Boolean,
        required:true,
    },
    wantToOfferRide:{
        type: Boolean,
        required:true,
    },
    pay: {
        type: Number,
        required: true,
    },
    notes: {
        type: String,
        max: 100
    }
},{ timestamps: true }
); 

module.exports = mongoose.model("UberList", UberListSchema);