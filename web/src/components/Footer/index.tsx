import Link from 'next/link'
import styles from './index.module.css'

const Footer = () => {
	return (
		<footer className={styles.footer}>
			<ul>
				<li>
					<h4>Tech Stuff</h4>
					<ul>
						<li><Link href="#">C++</Link></li>
						<li><Link href="#">TypeScript</Link></li>
						<li><Link href="#">Ruby</Link></li>
						<li><Link href="#">Terraform</Link></li>
						<li><Link href="#">Golang</Link></li>
						<li><Link href="#">Python</Link></li>
						<li><Link href="#">Cloud - AWS</Link></li>
						<li><Link href="#">Git</Link></li>
					</ul>
				</li>
				<li>
					<h4>Skills</h4>
					<ul>
						<li><Link href="#">Algorithms and Data Structures</Link></li>
						<li><Link href="#">Mathematics</Link></li>
						<li><Link href="#">Software Engineering</Link></li>
						<li><Link href="#">Web Development</Link></li>
						<li><Link href="#">Continuous Integration</Link></li>
						<li><Link href="#">Tech Agnostic</Link></li>
						<li><Link href="#">Proactivity</Link></li>
						<li><Link href="#">Continuous Learning</Link></li>
					</ul>
				</li>
				<li>
					<h4>Personal Projects</h4>
					<ul>
						<li><Link href="#">Algorists Group</Link></li>
						<li><Link href="#">Unit Test Zeal</Link></li>
						<li><Link href="#">Personal Website</Link></li>
						<li><Link href="#">Jarnik Build System</Link></li>
						<li><Link href="#">Spectral Clustering</Link></li>
					</ul>
				</li>
				<li>
					<h4>Volunteering</h4>
					<ul>
						<li><Link href="#">LEGO Robotics and Tech for Kids</Link></li>
						<li><Link href="#">Plant Trees</Link></li>
						<li><Link href="#">OmegaUp Latinoamerica</Link></li>
						<li><Link href="#">Rider Photoshoot</Link></li>
						<li><Link href="#">Charity Events</Link></li>
					</ul>
				</li>
				<li>
					<h4>Hobbies and fun</h4>
					<ul>
						<li><Link href="#">Cooking</Link></li>
						<li><Link href="#">Liverpool FC</Link></li>
						<li><Link href="#">Anime</Link></li>
						<li><Link href="#">Videogames</Link></li>
						<li><Link href="#">Boardgames</Link></li>
						<li><Link href="#">Watching sports</Link></li>
						<li><Link href="#">Travel and Hiking</Link></li>
					</ul>
				</li>
				<li>
					<h4>Hates and boring</h4>
					<ul>
						<li><Link href="#">Apple stuff</Link></li>
						<li><Link href="#">Real Madrid FC</Link></li>
						<li><Link href="#">Java stuff</Link></li>
					</ul>
				</li>
			</ul>
		</footer>
	)
}

export default Footer
