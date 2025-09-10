import React,{ useState } from 'react';
import { Card, CardContent, Link, Grid, TextField, Button } from '@material-ui/core';
import Alert from '@material-ui/lab/Alert';
import { useHistory,useParams } from 'react-router-dom';
import { Auth } from "aws-amplify";
import { handleFormValue } from 'utils/form.utility';

export const ResetPassword = ()=>{
    let history = useHistory();
    const [error, setError] = useState('');
    const [mode, setMode] = useState(0);
    const [form, setForm] = useState({
        code: "",
        pwd: "",
        email:"",
    });

    const {login} = useParams<any>();

    const resetPwd = async () => {
        setError('');

        if(mode === 0) {
            const result = await Auth.forgotPassword(form.email)
            .catch((e=>e));
            
            if(result && result.message) {
                setError(result.message)
                return;
            }

            setMode(1);
        } else {

            if(!form.pwd){
                setError('Password is required')
                return;
            }

            if(!form.code){
                setError('Verification code is required')
                return;
            }

            const verify  = await Auth.forgotPasswordSubmit(form.email,form.code,form.pwd)
            .catch((e=>e));

            if(verify && verify.message){
                setError(verify.message);
                return;
            }
            
            history.push("/login");
        }
    }

    return (
        <Card className="login-card">
            <CardContent>

                {error && (
                    <Alert className="mb-8" severity="error">{error}</Alert>
                )}

                <Grid container spacing={3}>

                    {mode === 0 ? (
                        <Grid item xs={12} className="left ml-32 mt-16 mr-32">
                            <TextField onChange={(e) => handleFormValue(e, "email", form, setForm)}  label="Email or phone number" />
                        </Grid>
                    ):(
                        <>
                        <Grid item xs={12} className="left ml-32 mt-16 mr-32">
                            <TextField  onChange={(e) => handleFormValue(e, "code", form, setForm)}    label="Verification code" />
                         </Grid>

                        <Grid item xs={12} className="left ml-32 mr-32">
                            <TextField  type="password" onChange={(e) => handleFormValue(e, "pwd", form, setForm)}  label="Password" />
                        </Grid>
                        </>
                    )}
                   
                    <Grid item xs={12} className="ml-32  mr-32">
                        <Button onClick={resetPwd} variant="contained" color="secondary">
                            {mode === 0 ? 'Reset Password':'Verify Code'}
                        </Button>
                    </Grid>

                    {!login && (
                        <Grid item xs={12}>
                            <Link onClick={() => history.push('/login')} color="textSecondary" className="f-25">Sign In</Link>
                        </Grid>
                    )}
                </Grid>
            </CardContent>
        </Card>
    )
}