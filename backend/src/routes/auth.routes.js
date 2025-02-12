const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

const JWT_SECRET = 'your-secret-key';

router.post('/register', async (req, res) => {
    try {
        console.log('Получены данные:', req.body);
        const { name, email, password } = req.body;
        console.log('Распакованные данные:', { name, email, password: '***' });

        if (!name || !email || !password) {
            console.log('Отсутствуют обязательные поля:', {
                hasName: !!name,
                hasEmail: !!email,
                hasPassword: !!password
            });
            return res.status(400).json({ 
                message: 'Все поля обязательны для заполнения',
                missing: {
                    name: !name,
                    email: !email,
                    password: !password
                }
            });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            console.log('Пользователь с email уже существует:', email);
            return res.status(400).json({ message: 'Пользователь уже существует' });
        }

        const user = new User({ name, email, password });
        await user.save();
        console.log('Пользователь успешно создан:', email);

        res.status(201).json({ message: 'Пользователь успешно создан' });
    } catch (error) {
        console.error('Детали ошибки регистрации:', error);
        res.status(500).json({ 
            message: 'Ошибка сервера: ' + error.message 
        });
    }
});

router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ message: 'Пользователь не найден' });
        }

        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(400).json({ message: 'Неверный пароль' });
        }

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '24h' });
        res.json({ token });
    } catch (error) {
        res.status(500).json({ message: 'Ошибка сервера' });
    }
});

module.exports = router; 