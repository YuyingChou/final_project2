const mongoose = require('mongoose');

const TraderSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        min: 1,
        max: 100,
    },
    studentID: {
        type: String,
        unique: true,
      },
    phone: {
        type: String, 
        unique: true,
      },
    email:{
        type: String,
        required: true,
    },
    departmentclass: {
        type: String,
    },
},{ timestamps: true }
); 

module.exports = mongoose.model("Trader", TraderSchema);