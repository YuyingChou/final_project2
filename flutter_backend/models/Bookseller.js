const mongoose = require('mongoose');

const BooksellerSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        min: 1,
        max: 100,
    },
    phone: {
        type: String, 
        unique: true,
      },
    email:{
        type: String,
        required: true,
    },
},{ timestamps: true }
); 

module.exports = mongoose.model("Bookseller", BooksellerSchema);