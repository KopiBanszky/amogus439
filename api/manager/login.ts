import { apiMethod } from "../../source/utility";
import dotenv from 'dotenv';

dotenv.config();
export default <apiMethod> {
    path: '/api/manager/login',
    method: 'POST',
    handler: function (req:any, res:any) {
        const {password} = req.body;     
        if(password === process.env.MANAGER_PASS){
            res.status(200).send({
                ok: true,
                message: 'Login successful',
            });
            return 200;
        }
        else{
            res.status(403).send({
                ok: false,
                message: 'Login failed',
            });
            return 403;
        }
    }
};