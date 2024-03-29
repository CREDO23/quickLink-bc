import { Router } from 'express';
import LinkControllers from '../controllers/link';

const linkRouter = Router();

linkRouter.post('/shorten', LinkControllers.create);
linkRouter.delete('/delete/:id', LinkControllers.delete);
linkRouter.get('/', LinkControllers.getByUser)

export default linkRouter;
