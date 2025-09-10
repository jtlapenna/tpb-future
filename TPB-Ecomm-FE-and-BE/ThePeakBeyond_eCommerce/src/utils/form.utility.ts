export const handleFormValue = (e: any, key: string, data: any, setFormData: any) => {
    setFormData({
        ...data,
        [key]: e.target.value,
    })
}