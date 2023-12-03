const express = require('express');
const router = express.Router();
const Info = require('../../models/Infos');
const bcrypt = require('bcrypt');

// publishHouse
router.post('/publishHouse', async (req, res) => {
    try {
        const houseData = req.body;
        console.log("Received house data:", houseData);

        const newHouse = new Info({
            username: req.body.username,
            department: req.body.department,
            email: req.body.email,
            roomType: houseData.roomType,
            title: houseData.title,
            location: houseData.location,
            price: houseData.price,
            landlordName: houseData.landlordName,
            landlordContact: houseData.landlordContact,
            expectedEndDate: houseData.expectedEndDate,
            rating: houseData.rating,
            image: houseData.image,
            facilities: houseData.facilities,
            comment: houseData.comment, // 新增評論
        });

        const savedHouse = await newHouse.save();

        res.status(200).json({ success: true, message: "发布成功", data: savedHouse });
    } catch (err) {
        res.status(400).json({ success: false, error: err.message });
    }
});

// getRentItems
router.get('/getRentItems', async (req, res) => {
    try {
        const rentItems = await Info.find();
        res.status(200).json({ success: true, data: rentItems });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

// deleteRentItem
router.delete('/deleteRentItem/:title', async (req, res) => {
    try {
        const title = req.params.title;

        // Find and remove the rental item by title
        const deletedItem = await Info.findOneAndRemove({ title });

        if (!deletedItem) {
            return res.status(404).json({ success: false, error: 'Item not found' });
        }

        res.status(200).json({ success: true, message: 'Item deleted successfully', data: deletedItem });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

router.put('/editHouse/:title', async (req, res) => {
    try {
        const title = req.params.title;
        const updatedHouseData = req.body;

        // Find and update the rental item by title
        const updatedHouse = await Info.findOneAndUpdate(
            { title },
            { $set: updatedHouseData },
            { new: true }
        );

        if (!updatedHouse) {
            return res.status(404).json({ success: false, error: 'Item not found' });
        }

        res.status(200).json({ success: true, message: 'Item updated successfully', data: updatedHouse });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});

router.get('/getSimilarHouses/:location', async (req, res) => {
    try {
        const location = req.params.location;

        // Find rental items by location
        const rentItemsByLocation = await Info.find({ location });

        if (rentItemsByLocation.length === 0) {
            return res.status(404).json({ success: false, error: 'No items found for the specified location' });
        }

        res.status(200).json({ success: true, data: rentItemsByLocation });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Internal Server Error' });
    }
});



module.exports = router;