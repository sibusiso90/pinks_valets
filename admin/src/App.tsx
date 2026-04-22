import { Route, Routes } from "react-router-dom";
import Dashboard from "./pages/Dashboard";
import Bookings from "./pages/Bookings";
import BookingDetail from "./pages/BookingDetail";
import Schedule from "./pages/Schedule";
import Services from "./pages/Services";
import Payments from "./pages/Payments";
import Customers from "./pages/Customers";
import CustomerDetail from "./pages/CustomerDetail";
import Settings from "./pages/Settings";

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/bookings" element={<Bookings />} />
      <Route path="/bookings/:id" element={<BookingDetail />} />
      <Route path="/schedule" element={<Schedule />} />
      <Route path="/services" element={<Services />} />
      <Route path="/payments" element={<Payments />} />
      <Route path="/customers" element={<Customers />} />
      <Route path="/customers/:id" element={<CustomerDetail />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}
