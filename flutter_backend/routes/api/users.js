const router = require('express').Router();
const User = require('../../models/User');
const bcrypt = require('bcrypt');

//register
router.post('/register',async (req, res)=>{
    try {
        //generate a password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(req.body.password,salt);
        
        //create new user
        const newUser = new User({
            username: req.body.username,
            email: req.body.email,
            password: hashedPassword,
            studentId: req.body.studentId,
            Department: req.body.Department,
            Year: req.body.Year,
            gender: req.body.gender,
            phoneNumber: req.body.phoneNumber
        });

        //save user and sned response
        const user = await newUser.save();
        res.status(200).json({ success: true, message: "註冊成功" });
    } catch (err) {
        res.status(400).json({ success: false, error: err.message });
    }
});

//login
router.post('/login', async (req, res) => {
    try {
        //find user
        const user = await User.findOne({ username: req.body.username });
        if (!user) {
            return res.status(400).json("使用者名稱或密碼錯誤!");
        }
        //validate password
        const validPassword = await bcrypt.compare(
            req.body.password,
            user.password
        );
        if (!validPassword) {
            return res.status(400).json("使用者名稱或密碼錯誤!");
        }
        //send response
        return res.status(200).json({ _id: user._id, username: user.username });
    } catch (err) {
        return res.status(400).json(err);
    }
});

//get user information
router.get('/user/:id', async (req, res) => {
    try {
      const userId = req.params.id;
      const user = await User.findOne({ _id: userId }); 
      if (user) {
        return res.status(200).json(user);
      } else {
        return res.status(400).json({ message: '使用者不存在' });
      }
    } catch (err) {
      return res.status(500).json({ message: '伺服器發生錯誤' });
    }
});

//edit user profile
router.put('/:id', async (req, res) => {
    try {
      const updatedUser = await User.findByIdAndUpdate(
        req.params.id, 
        req.body, 
        { new: true }
      );
      if (!updatedUser) {
        res.status(400).json({ message: '找不到此用户' });
        return;
      } 
      res.status(200).json(updatedUser);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: '服务器错误' });
    }
});

router.post('/checkEmailRegistration', async (req, res) => {
    try {
        const existingUser = await User.findOne({ email: req.body.email });
        const isRegistered = !!existingUser;

        res.status(200).json({ isRegistered });
    } catch (err) {
        res.status(500).json({ message: '伺服器發生錯誤' });
    }
});

router.put('/change-password/:email', async (req, res) => {
  try {
    const userEmail = req.params.email;
    const newPassword = req.body.newPassword;

    // 在資料庫中使用 email 找到用戶
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ success: false, message: '找不到此用户' });
    }

    // 使用 bcrypt 進行密碼加密
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 更新用戶密碼
    user.password = hashedPassword;
    await user.save();

    // 返回成功的回應
    res.status(200).json({ success: true, message: '密碼修改成功' });
  } catch (error) {
    console.error('Error changing password:', error);
    res.status(500).json({ success: false, message: '密碼修改失敗' });
  }
});

router.get('/:email', async (req, res) => {
  try {
    const userEmail = req.params.email;
    const user = await User.findOne({ email: userEmail });

    if (!user) {
      return res.status(404).json({ success: false, message: '找不到此用户' });
    }

    // 在数据库中使用email查找用户
    res.status(200).json({ success: true, username: user.username, password: user.password });
  } catch (error) {
    console.error('Error fetching username:', error);
    res.status(500).json({ success: false, message: '获取用户名失败' });
  }
});

router.delete('/:email', async (req, res) => {
  try {
      const userEmail = req.params.email;

      // Find the user by email
      const user = await User.findOne({ email: userEmail });

      if (!user) {
          return res.status(404).json({ success: false, message: '找不到此用户' });
      }

      // Delete the user
      await User.findOneAndDelete({ email: userEmail });

      // Respond with success message
      res.status(200).json({ success: true, message: '用户删除成功' });
  } catch (err) {
      console.error('Error deleting user:', err);
      res.status(500).json({ success: false, message: '用户删除失败' });
  }
});

router.get('/username/:username', async (req, res) => {
    try {
        const username = req.params.username;

        // Find the user by username
        const user = await User.findOne({ username: username });

        if (!user) {
            return res.status(404).json({ success: false, message: '找不到此用户' });
        }

        // Respond with user information
        res.status(200).json({
            success: true,
            user: {
                _id: user._id,
                username: user.username,
                email: user.email,
                // Add other user properties as needed
            }
        });
    } catch (err) {
        console.error('Error fetching user information:', err);
        res.status(500).json({ success: false, message: '获取用户信息失败' });
    }
});

module.exports = router;