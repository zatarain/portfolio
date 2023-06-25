import NavigationBar from '#components/NavigationBar';
import Head from 'next/head';
import { ReactNode } from 'react';
import { Inter } from 'next/font/google'
import Footer from '#components/Footer';

interface Properties {
	children?: ReactNode
	data: any
	title?: string
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
			</header>
			<main>
				{children}
			</main>
			<Footer />
		</div>
	)
}
