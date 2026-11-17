/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        gym: {
          bg: '#0B0F19',
          surface: '#121A2D',
          card: '#18233C',
          cardHover: '#22304E',
          border: '#263554',
          primary: '#6366F1',
          violet: '#8B5CF6',
          purple: '#A855F7',
          accent: '#10B981',
          warning: '#F59E0B',
          streak: '#FB923C',
          danger: '#EF4444',
        }
      }
    },
  },
  plugins: [],
}
