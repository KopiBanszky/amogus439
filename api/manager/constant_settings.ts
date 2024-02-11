import {isEmpty, apiMethod} from '../../source/utility';

export const settings = {
    sabotage_coolwown: 10,
};

export default <apiMethod> {
    path: '/api/manager/settings',
    method: 'GET',
    handler: function (req:any, res:any) {
        res.status(200).json(settings);
    }
}