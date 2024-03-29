import * as express from 'express';
import * as http from 'http';
import * as httpErrors from 'http-errors';
import * as cors from 'cors';
import * as morgan from 'morgan';
import { connect_db } from './models';
import authRouter from './routes/auth';
import { tokenGuard } from './middlewares/tokenGuard';
import linkRouter from './routes/link';
import router from './routes';

class App {
  private app: express.Application = express();
  public server: http.Server = http.createServer(this.app);

  public async init(): Promise<http.Server> {
    this.connectDB();
    this.middlewares();
    this.routes();
    this.errorsHandler();
    return this.server;
  }

  private connectDB(): void {
    connect_db();
  }

  private middlewares(): void {
    this.app.use(cors());
    this.app.use(morgan(':method :url :status :response-time ms'));
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: false }));
  }

  private routes(): void {
    this.app.get('/', (req: express.Request, res: express.Response) => {
      res.send('Server is running');
    });
    this.app.use('',router)
    this.app.use('/v1/auth', authRouter);
    this.app.use('/v1/links', tokenGuard, linkRouter);
  }

  private errorsHandler(): void {
    this.app.use(
      (
        req: express.Request,
        res: express.Response,
        next: express.NextFunction,
      ) => {
        next(httpErrors.NotFound('URL not found'));
      },
    );

    this.app.use(
      (
        error: any,
        req: express.Request,
        res: express.Response,
        next: express.NextFunction,
      ) => {
        res.status(error.isJoi ? 422 : error.status || 500);

        res.json(<IClientResponse>{
          message: error.message,
          data: null,
          error,
          success: false,
        });
      },
    );
  }
}

export default App;
