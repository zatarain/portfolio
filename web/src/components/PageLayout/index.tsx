import Head from 'next/head';
import { ReactNode } from 'react';
import { Inter } from 'next/font/google'
import Image from 'next/image';
import Link from 'next/link'
import HeroSlider from '#components/HeroSlider'

interface Properties {
	children?: ReactNode
	data: any
	title?: string
}

const images = {
	Liverpool: '002',
	Germany: '003',
	Netherlands: '004',
	Norway: '005',
	Scotland: '006',
}

const inter = Inter({ subsets: ['latin'] })

export default function PageLayout({ children, title, data }: Properties) {
	const pageTitle = [data?.name, title].filter(part => !!part).join(' - ')
	return (
		<div className={`${inter.className} container`}>
			<Head>
				<title>{pageTitle}</title>
				<link rel="icon" href="/favicon.ico" />
			</Head>
			<header>
				<nav>
					<div>
						<div className="pages">
							<Link href="/" className="logo">
								<Image alt="logo" src="/logo.svg" width="48" height="48" />
								{data?.name}
							</Link>
							<div className="sections">
								<Link href="/">Home</Link>
								<Link href="#">Experience</Link>
								<Link href="#">Education</Link>
								<Link href="#">Skills</Link>
								<Link href="#">Projects</Link>
								<Link href="#">Contact</Link>
							</div>
						</div>
						<div className="actions">
							<Link href="#">E-mail</Link>
							<Link href="#" className="call-to-action">Download</Link>
						</div>
					</div>
				</nav>
				<HeroSlider images={images} />
			</header>
			<main>
				{children}
			</main>
			<footer>
				<ul>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Products</h4>
						<ul>
							<li><a href="#">Features</a></li>
							<li><a href="#">Integrations</a></li>
							<li><a href="#">Enterprice</a></li>
							<li><a href="#">Solutions</a></li>
						</ul>
					</li>
					<li>
						<h4>Resources</h4>
						<ul>
							<li><a href="#">Partners</a></li>
							<li><a href="#">Developers</a></li>
							<li><a href="#">Community</a></li>
							<li><a href="#">Apps</a></li>
						</ul>
					</li>
					<li>
						<h4>Company</h4>
						<ul>
							<li><a href="#">About us</a></li>
							<li><a href="#">Leadership</a></li>
						</ul>
					</li>
				</ul>
			</footer>
		</div>
	)
}
