const mongoose = require('mongoose');

const InfoSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
    },
    department: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    roomType: {
        type: String,
        required: true,
    },
    title: {
        type: String,
        required: true,
    },
    location: {
        type: String,
        required: true,
    },
    price: {
        type: String,
        required: true,
    },
    landlordName: {
        type: String,
        required: true,
    },
    landlordContact: {
        type: String,
        required: true,
    },
    expectedEndDate: {
        type: String,
        required: true,
    },
    rating: {
        type: Number,
        required: true,
    },
    image: {
        type: String,
    },
    facilities: {
        type: [String],
    },
    publishTime: {
        type: Date,  // 使用 Date 類型來存儲時間
        default: Date.now,  // 默認值為當前時間
    },
    comment: {
        type: String,
        required: true,
    },
}, { timestamps: true });

module.exports = mongoose.model("Info", InfoSchema);