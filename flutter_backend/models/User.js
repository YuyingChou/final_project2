const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        min: 3,
        max: 20,
        unique: true,
    },
    email:{
        type: String,
        required: true,
        max: 50,
        unique: true,
    },
    password:{
        type: String,
        required: true,
        min: 6,
    },
    studentId:{
        type: String,
        required: true,
        max: 10,
        unique: true,
    },
    Department:{
        type: String,
        required: true,
    },
    Year:{
        type: String,
        required: true,
    },
    gender:{
        type: String,
        required: true,
    },
    phoneNumber:{
        type: String,
        required: true,
        max: 11
    }
},{ timestamps: true }
); 

module.exports = mongoose.model("User", UserSchema);