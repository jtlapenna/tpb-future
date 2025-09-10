import React from "react";
import { Backdrop, CircularProgress } from "@material-ui/core";

export class Spinner extends React.Component {
    static Instance: any;

    static hide() {
        Spinner.Instance.setState({
            open: false,
        });
    }

    static show() {

        if (Spinner.Instance) {
            Spinner.Instance.setState({
                open: true,
            });


        } else {
            console.warn('No modal found');
        }
    }

    constructor(props:any) {
        super(props);

        this.state = {
            open: false,
        };

        Spinner.Instance = this;
    }

    handleClose = () => {
        this.setState({ open: false });
    };

    render() {
        const { open } = this.state as any;

        return <Backdrop style={{ zIndex: 999, color: '#fff' }} open={open}>
            <CircularProgress color="inherit" />
        </Backdrop>
    }

}