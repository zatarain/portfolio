/** @type {import('next').NextConfig} */

const nextConfig = {
	transpilePackages: [
		'react-leaflet-cluster',
	],
	images: {
		domains: [
			'cdn.instagram.com',
			'cdn-icons-png.flaticon.com',
			'i.gifer.com',
		],
		remotePatterns: [
			{
				protocol: 'https',
				hostname: '**.cdninstagram.com',
			},
		],
	},
};

module.exports = nextConfig;
