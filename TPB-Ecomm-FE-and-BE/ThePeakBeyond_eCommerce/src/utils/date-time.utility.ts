import moment from "moment";

export const formatTime = (date: Date) => {
    return moment(date).format("hh:mm A");
}

export const formatDate = (date: Date) => {
    return moment(date).format("M-D-YYYY");
}