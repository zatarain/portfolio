/** @type {import('next').NextConfig} */

const nextConfig = {
	transpilePackages: [
		'react-leaflet-cluster',
	],
	images: {
		remotePatterns: [
			{
				protocol: 'https',
				hostname: 'i.gifer.com',
			},
			{
				protocol: 'https',
				hostname: '**.cdninstagram.com',
			},
			{
				protocol: 'https',
				hostname: 'cdn-icons-png.flaticon.com',
			},
		],
	},
};

module.exports = nextConfig;
