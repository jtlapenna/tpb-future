import { Shelf } from "./shelf.interface";

export interface Rack {
    shelf: Shelf[];
    title: string;
}