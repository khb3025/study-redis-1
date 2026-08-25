import http from 'k6/http';
import { sleep } from 'k6';


export const options = {
    stages: [
        { duration: '10s', target: 30 } // simulate up to 100 VUs
    ]
};

export default function () {
    // Make a GET request to the target URL
    http.get('http://43.201.8.31:8080/boards');

}