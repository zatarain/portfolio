/** @type {import('next').NextConfig} */

const nextConfig = {
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
