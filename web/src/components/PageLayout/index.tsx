import Head from 'next/head';
import { ReactNode } from 'react';
import { Inter } from 'next/font/google'
import Image from 'next/image';

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
				<link rel="icon" href="/favicon.ico" />
			</Head>
			<header>
				<nav>
					<div>
						<div className="pages">
							<a href="/" className="logo">
								<Image alt="logo" src="/logo.svg" width="48" height="48" />
								{data?.name}
							</a>
							<div className="sections">
								<a href="/">Home</a>
								<a href="#">Experience</a>
								<a href="#">Education</a>
								<a href="#">Skills</a>
								<a href="#">Projects</a>
								<a href="#">Contact</a>
							</div>
						</div>
						<div className="actions">
							<a href="#">E-mail</a>
							<a href="#" className="call-to-action">Download</a>
						</div>
					</div>
				</nav>
				<div className="hero">
					<Image alt="me" src="/me/001.jpg" width="1440" height="1080" />
				</div>
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
