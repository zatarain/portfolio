/** @type {import('next').NextConfig} */

const nextConfig = {
	transpilePackages: [
		'react-leaflet-cluster',
	],
	images: {
		domains: [
			'cdn.instagram.com',
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
