/** @type {import('next').NextConfig} */

const nextConfig = {
	transpilePackages: [
		'react-leaflet-cluster',
	],
	images: {
		domains: [
			'cdn.instagram.com',
			'i.gifer.com',
		],
		remotePatterns: [
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
