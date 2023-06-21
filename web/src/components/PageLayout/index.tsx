import NavigationBar from '#components/NavigationBar';
import Head from 'next/head';
import { ReactNode } from 'react';
import { Inter } from 'next/font/google'
import HeroSlider from '#components/HeroSlider'
import Footer from '#components/Footer';

interface Properties {
	children?: ReactNode
	data: any
	title?: string
}

const images = {
	Liverpool: 'https://instagram.flhr4-3.fna.fbcdn.net/v/t51.2885-15/342896197_1248293092495230_6411713721524265006_n.jpg?stp=dst-jpg_e35_s1080x1080&_nc_ht=instagram.flhr4-3.fna.fbcdn.net&_nc_cat=106&_nc_ohc=dpc0qoaSBjQAX-Iza3f&edm=AJ9x6zYBAAAA&ccb=7-5&ig_cache_key=MzA4OTEzNzcwNTM5MTYzODU0Mw%3D%3D.2-ccb7-5&oh=00_AfAo7LgVSIeQ22TYa3wgUnGZAny7iHK-x16JPQBX4TSx4w&oe=644DA0A4&_nc_sid=cff2a4',
	Greenwich: 'https://instagram.flhr4-3.fna.fbcdn.net/v/t51.2885-15/343022676_588960466631005_1375885274036940655_n.jpg?stp=dst-jpg_e35_s1080x1080&_nc_ht=instagram.flhr4-3.fna.fbcdn.net&_nc_cat=101&_nc_ohc=-ogmS4MlyxkAX_2f1a4&edm=AJ9x6zYBAAAA&ccb=7-5&ig_cache_key=MzA4OTEzNjk1MDY2ODY4Mjk2MQ%3D%3D.2-ccb7-5&oh=00_AfB-JYQIliGJ9Lo2RaqsCLMbs7r8_3sXmeidDgUmGh4Aag&oe=644DF024&_nc_sid=cff2a4',
	Norway: 'https://instagram.flhr4-3.fna.fbcdn.net/v/t51.2885-15/342921583_250685550681837_6177327967597128456_n.jpg?stp=dst-jpg_e35_s1080x1080&_nc_ht=instagram.flhr4-3.fna.fbcdn.net&_nc_cat=109&_nc_ohc=WHOQPoPcYwEAX9UI-gH&edm=AJ9x6zYBAAAA&ccb=7-5&ig_cache_key=MzA4OTEzODE3NDQwNzAwOTc4OA%3D%3D.2-ccb7-5&oh=00_AfDqa1SDFfmEjo00iioVkCd1I2zB0CPq12lcR4ivdJcxLg&oe=644E026C&_nc_sid=cff2a4',
}

const inter = Inter({ subsets: ['latin'] })

export default function PageLayout({ children, title, data }: Properties) {
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	return (
		<div className={`${inter.className} container`}>
			<Head>
				<title>{pageTitle}</title>
			</Head>
			<header>
				<NavigationBar name={data?.name} />
				<HeroSlider images={images} />
			</header>
			<main>
				{children}
			</main>
			<Footer />
		</div>
	)
}
