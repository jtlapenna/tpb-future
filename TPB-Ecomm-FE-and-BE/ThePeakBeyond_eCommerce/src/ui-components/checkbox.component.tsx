
import Checkbox, { CheckboxProps } from '@material-ui/core/Checkbox';
import { withStyles } from '@material-ui/core/styles';
import { green } from '@material-ui/core/colors';

const AppCheckbox = withStyles({
    root: {
        color: 'white',
        transform: "scale(1.7)",
        
        "&:not($checked) .MuiIconButton-label:after": {
            content: '""',
            height: 15,
            width: 15,
            position: "absolute",
            backgroundColor: "white",
            zIndex: -1
        },

        '&$checked': {
            color: green[600],
        },

        
    },
    checked: {},
})((props: CheckboxProps) => <Checkbox size='medium' color="default" {...props} />);

export const GreenCheckbox = ({ ...props }) => {
    return (
        <AppCheckbox
            {...props}
        />
    )
}