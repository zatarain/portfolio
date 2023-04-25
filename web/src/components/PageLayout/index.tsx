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
								<Link href="#">Hobbies</Link>
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
						<h4>Tech Stuff</h4>
						<ul>
							<li><a href="#">C++</a></li>
							<li><a href="#">TypeScript</a></li>
							<li><a href="#">Ruby</a></li>
							<li><a href="#">Terraform</a></li>
							<li><a href="#">Golang</a></li>
							<li><a href="#">Python</a></li>
							<li><a href="#">Cloud - AWS</a></li>
							<li><a href="#">Git</a></li>
						</ul>
					</li>
					<li>
						<h4>Skills</h4>
						<ul>
							<li><a href="#">Algorithms and Data Structures</a></li>
							<li><a href="#">Mathematics</a></li>
							<li><a href="#">Software Engineering</a></li>
							<li><a href="#">Web Development</a></li>
							<li><a href="#">Continuous Integration</a></li>
							<li><a href="#">Tech Agnosticity</a></li>
							<li><a href="#">Proactivity</a></li>
							<li><a href="#">Continuous Learning</a></li>
						</ul>
					</li>
					<li>
						<h4>Personal Projects</h4>
						<ul>
							<li><a href="#">Algorists Group</a></li>
							<li><a href="#">Unit Test Zeal</a></li>
							<li><a href="#">Personal Website</a></li>
							<li><a href="#">Jarnik Build System</a></li>
							<li><a href="#">Spectral Clustering</a></li>
						</ul>
					</li>
					<li>
						<h4>Volunteering</h4>
						<ul>
							<li><a href="#">LEGO Robotics and Tech for Kids</a></li>
							<li><a href="#">Plant Trees</a></li>
							<li><a href="#">OmegaUp Latinoamerica</a></li>
							<li><a href="#">Rider Photoshoot</a></li>
							<li><a href="#">Charity Events</a></li>
						</ul>
					</li>
					<li>
						<h4>Hobbies and fun</h4>
						<ul>
							<li><a href="#">Cooking</a></li>
							<li><a href="#">Liverpool FC</a></li>
							<li><a href="#">Anime</a></li>
							<li><a href="#">Videogames</a></li>
							<li><a href="#">Boardgames</a></li>
							<li><a href="#">Watching sports</a></li>
							<li><a href="#">Travel and Hiking</a></li>
						</ul>
					</li>
					<li>
						<h4>Hates and boring</h4>
						<ul>
							<li><a href="#">Apple stuff</a></li>
							<li><a href="#">Real Madrid FC</a></li>
							<li><a href="#">Java stuff</a></li>
						</ul>
					</li>
				</ul>
			</footer>
		</div>
	)
}
