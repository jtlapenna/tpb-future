import { LoginDto } from "../types/login.dto";
import { Spinner } from "../ui-components/spinner.component";
import { getBearerToken, setBearerToken, setUserInfo } from "../utils/local-storage.utility";
import { httpPost } from "./http-client.service";

export const IsUserLoggedIn = () => getBearerToken() !== "";

export const logout = () => {
    setBearerToken("");
    setUserInfo(null);
}

export const doLogin = async (loginDto: LoginDto) => {
    Spinner.show();
    const loginResult = await httpPost(`Auth/login`, loginDto)
        .catch((e) => e);

    Spinner.hide();

    if (loginResult) {
        setUserInfo(loginResult);
        setBearerToken(loginResult.token);

        return loginResult;
    }

    return null;
}